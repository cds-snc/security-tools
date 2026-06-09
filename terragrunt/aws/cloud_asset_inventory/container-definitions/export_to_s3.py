#!/usr/bin/env python3
"""Export cartography Neo4j graph snapshots to S3 for Sentinel forwarding.

Runs as the finalizer container of the cartography task (after the scan), reusing
the cartography image (which ships the neo4j driver + boto3).

The exporter is intentionally PROPERTY-NAME-AGNOSTIC: it dumps full property maps
verbatim for both nodes and relationships. It emits chunked JSON array files under
run-specific prefixes and writes a manifest consumed by the GitHub forwarding
workflow.

Required environment:
    NEO4J_URI                    - bolt URI (the internal NLB)
    NEO4J_USER                   - neo4j username
    NEO4J_SECRETS_PASSWORD       - neo4j password (injected from SSM)
    EXPORT_BUCKET                - S3 bucket for exports. If unset, writes to EXPORT_DIR.
    EXPORT_PREFIX                - export key prefix (default "sentinel-exports")
    EXPORT_DIR                   - local output dir when EXPORT_BUCKET is unset (default ".")
    EXPORT_RUN_PREFIX            - run folder namespace under EXPORT_PREFIX (default "runs")
    EXPORT_MAX_RECORDS_PER_FILE  - records per chunk file (default 2000)
"""
import datetime
import glob
import json
import os
import sys
from dataclasses import dataclass

# boto3 + neo4j ship inside the cartography image's uv-managed tool environment,
# not on the system python3 path. Add it (see generate_config.py for the rationale).
for _pattern in (
    "/var/cartography/.local/share/uv/tools/*/lib/python*/site-packages",
    "/var/cartography/.local/lib/python*/site-packages",
):
    sys.path[:0] = glob.glob(_pattern)

import boto3  # noqa: E402  (imported after the sys.path bootstrap above)
from neo4j import GraphDatabase  # noqa: E402

# Generic, property-name-agnostic exports. No filters or projections; all
# curation happens in KQL on the Sentinel side.
NODES_QUERY = (
    "MATCH (n) "
    "RETURN labels(n) AS labels, properties(n) AS properties, elementId(n) AS element_id"
)
RELATIONSHIPS_QUERY = (
    "MATCH (a)-[r]->(b) "
    "RETURN type(r) AS rel_type, elementId(r) AS rel_id, "
    "elementId(a) AS start_node_id, elementId(b) AS end_node_id, "
    "properties(r) AS properties"
)


@dataclass
class ExportArtifact:
    key: str
    count: int


def _json_bytes(rows):
    return json.dumps(rows, default=str).encode("utf-8")


def _chunked(iterable, chunk_size):
    chunk = []
    for item in iterable:
        chunk.append(item)
        if len(chunk) >= chunk_size:
            yield chunk
            chunk = []
    if chunk:
        yield chunk


def _node_rows(records, run_ts):
    for record in records:
        yield {
            "TimeGenerated": run_ts,
            "NodeLabels": record["labels"],
            "NodeId": record["element_id"],
            "Properties": record["properties"],
        }


def _relationship_rows(records, run_ts):
    for record in records:
        yield {
            "TimeGenerated": run_ts,
            "RelType": record["rel_type"],
            "RelId": record["rel_id"],
            "StartNodeId": record["start_node_id"],
            "EndNodeId": record["end_node_id"],
            "Properties": record["properties"],
        }


def _write_bytes(bucket, key, body):
    boto3.client("s3").put_object(
        Bucket=bucket,
        Key=key,
        Body=body,
        ContentType="application/json",
    )


def _write_local(path, body):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as out:
        out.write(body)


def _export_entity_chunks(entity_name, row_iter, chunk_size, sink_writer, base_prefix):
    artifacts = []
    total = 0
    for idx, rows in enumerate(_chunked(row_iter, chunk_size), start=1):
        key = f"{base_prefix}/{entity_name}/{entity_name}-{idx:05d}.json"
        sink_writer(key, _json_bytes(rows))
        count = len(rows)
        total += count
        artifacts.append(ExportArtifact(key=key, count=count))
    return artifacts, total


def _manifest_dict(run_id, run_ts, base_prefix, node_artifacts, rel_artifacts, node_count, rel_count):
    return {
        "RunId": run_id,
        "GeneratedAt": run_ts,
        "BasePrefix": base_prefix,
        "Nodes": {
            "Count": node_count,
            "Files": [{"Key": a.key, "Count": a.count} for a in node_artifacts],
        },
        "Relationships": {
            "Count": rel_count,
            "Files": [{"Key": a.key, "Count": a.count} for a in rel_artifacts],
        },
    }


def main():
    uri = os.environ["NEO4J_URI"]
    user = os.environ["NEO4J_USER"]
    password = os.environ["NEO4J_SECRETS_PASSWORD"]
    bucket = os.environ.get("EXPORT_BUCKET")
    prefix = os.environ.get("EXPORT_PREFIX", "sentinel-exports").strip("/")
    local_dir = os.environ.get("EXPORT_DIR", ".")
    run_prefix = os.environ.get("EXPORT_RUN_PREFIX", "runs").strip("/")
    chunk_size = int(os.environ.get("EXPORT_MAX_RECORDS_PER_FILE", "2000"))

    if chunk_size <= 0:
        raise ValueError("EXPORT_MAX_RECORDS_PER_FILE must be greater than 0")

    run_ts = datetime.datetime.now(datetime.timezone.utc).isoformat()
    run_id = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    base_prefix = f"{prefix}/{run_prefix}/{run_id}"

    driver = GraphDatabase.driver(uri, auth=(user, password))
    try:
        with driver.session() as session:
            if bucket:
                sink_writer = lambda key, body: _write_bytes(bucket, key, body)
            else:
                sink_writer = lambda key, body: _write_local(
                    os.path.join(local_dir, key),
                    body,
                )

            node_artifacts, node_count = _export_entity_chunks(
                entity_name="nodes",
                row_iter=_node_rows(session.run(NODES_QUERY), run_ts),
                chunk_size=chunk_size,
                sink_writer=sink_writer,
                base_prefix=base_prefix,
            )
            rel_artifacts, rel_count = _export_entity_chunks(
                entity_name="relationships",
                row_iter=_relationship_rows(session.run(RELATIONSHIPS_QUERY), run_ts),
                chunk_size=chunk_size,
                sink_writer=sink_writer,
                base_prefix=base_prefix,
            )
    finally:
        driver.close()

    manifest = _manifest_dict(
        run_id=run_id,
        run_ts=run_ts,
        base_prefix=base_prefix,
        node_artifacts=node_artifacts,
        rel_artifacts=rel_artifacts,
        node_count=node_count,
        rel_count=rel_count,
    )
    manifest_body = _json_bytes(manifest)

    if bucket:
        run_manifest_key = f"{base_prefix}/manifest.json"
        latest_manifest_key = f"{prefix}/latest/manifest.json"
        _write_bytes(bucket, run_manifest_key, manifest_body)
        _write_bytes(bucket, latest_manifest_key, manifest_body)
        print(
            "wrote run "
            f"{run_id} to s3://{bucket}/{base_prefix} "
            f"(nodes={node_count}, relationships={rel_count}, "
            f"node_files={len(node_artifacts)}, rel_files={len(rel_artifacts)})"
        )
        print(f"manifest: s3://{bucket}/{run_manifest_key}")
        print(f"latest:   s3://{bucket}/{latest_manifest_key}")
    else:
        run_manifest_path = os.path.join(local_dir, base_prefix, "manifest.json")
        latest_manifest_path = os.path.join(
            local_dir,
            prefix,
            "latest",
            "manifest.json",
        )
        _write_local(run_manifest_path, manifest_body)
        _write_local(latest_manifest_path, manifest_body)
        print(
            "wrote run "
            f"{run_id} to {os.path.join(local_dir, base_prefix)} "
            f"(nodes={node_count}, relationships={rel_count}, "
            f"node_files={len(node_artifacts)}, rel_files={len(rel_artifacts)})"
        )
        print(f"manifest: {run_manifest_path}")
        print(f"latest:   {latest_manifest_path}")


if __name__ == "__main__":
    main()
