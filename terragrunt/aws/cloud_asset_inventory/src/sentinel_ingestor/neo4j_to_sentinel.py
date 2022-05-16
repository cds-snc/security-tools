import time
import datetime
import logging

# Import sentinel connector from lambda layer
import connector

from neo4j_connector import Neo4jConnector

logging.basicConfig()
logger = logging.getLogger("sentinel_ingestor")
logger.setLevel(logging.INFO)

# Preserve the connection for reuse
DB = Neo4jConnector()


def enrich_results(record, query, timestamp):
    """
    Enrich results from Neo4j with metadata needed by Sentinel
    """
    record["metadata.query_name"] = query["name"]
    record["metadata.query_id"] = "{}_{}".format(query["name"], timestamp)
    record["metadata.query_description"] = query["description"]
    record["metadata.query_headers"] = query["headers"]
    record["@timestamp"] = int(round(time.time() * 1000))
    return


def query_by_tag(tags):
    logger.info("Querying Neo4J by tags: {}".format(tags))
    return DB.query_by_tag(tags)


def push_results(results):
    logger.info("Pushing query results to Sentinel")
    timestamp = datetime.datetime.now().isoformat()
    for query in results:
        logger.debug(f"Processing query: {query['name']}")
        for row in query["results"]:
            enrich_results(row, query, timestamp)
            connector.handle_log({"application_log": row})


def handler(event, context):
    logger.info("Querying Noe4j")
    results = query_by_tag(["aws"])
    push_results(results)


if __name__ == "__main__":
    handler(None, None)
