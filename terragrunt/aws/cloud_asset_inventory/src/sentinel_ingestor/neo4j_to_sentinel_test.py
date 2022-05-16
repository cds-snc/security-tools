from unittest.mock import ANY, patch
import os

os.environ["CUSTOMER_ID"] = "test"
os.environ["LOG_TYPE"] = "test"
os.environ["NEO4J_URI"] = "bolt://neo4j.internal.local:7687"
os.environ["NEO4J_USER"] = "neo4j"
os.environ["NEO4J_SECRETS_PASSWORD"] = "secret"
os.environ["SHARED_KEY"] = "test"

import neo4j_to_sentinel  # noqa: E402


def test_enrich_results():
    record = {"foo": "bar"}
    query = {"name": "test", "description": "test", "headers": ["foo"]}
    timestamp = "2020-01-01T00:00:00.000Z"
    neo4j_to_sentinel.enrich_results(record, query, timestamp)
    assert record["metadata.query_name"] == "test"
    assert record["metadata.query_id"] == "test_2020-01-01T00:00:00.000Z"
    assert record["metadata.query_description"] == "test"
    assert record["metadata.query_headers"] == ["foo"]
    assert record["@timestamp"] == ANY


@patch("neo4j_to_sentinel.DB")
def test_query_by_tag(mock_db):
    mock_db.query_by_tag.return_value = {"test": ["foo", "bar"]}
    results = neo4j_to_sentinel.query_by_tag(["test"])
    assert results == {"test": ["foo", "bar"]}
    mock_db.query_by_tag.assert_called_once_with(["test"])


@patch("neo4j_to_sentinel.connector")
def test_push_results(mock_connector):
    results = [
        {
            "name": "test",
            "description": "test",
            "headers": ["foo"],
            "result": [{"foo": "bar"}],
        }
    ]
    neo4j_to_sentinel.push_results(results)
    mock_connector.handle_log.assert_called_once_with(
        {
            "application_log": {
                "foo": "bar",
                "metadata.query_name": "test",
                "metadata.query_id": ANY,
                "metadata.query_description": "test",
                "metadata.query_headers": ["foo"],
                "@timestamp": ANY,
            }
        }
    )


@patch("neo4j_to_sentinel.query_by_tag")
@patch("neo4j_to_sentinel.push_results")
def test_handler(mock_push_results, mock_query_by_tag):
    mock_query_by_tag.return_value = {"test": ["foo", "bar"]}
    neo4j_to_sentinel.handler(None, None)
    mock_query_by_tag.assert_called_once_with(["aws"])
    mock_push_results.assert_called_once_with({"test": ["foo", "bar"]})
