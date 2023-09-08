from unittest.mock import patch

import main


def test_handler_empty():
    assert main.handler({}, {}) == {"status": "ok"}


@patch("builtins.print")
def test_handler_csp_report_plain(mock_print):
    assert main.handler({"body": '{"csp-report": {"foo": "bar"}}'}, {}) == {
        "status": "ok"
    }
    mock_print.assert_called_with('{"csp-report": {"foo": "bar"}}')


@patch("builtins.print")
def test_handler_csp_report_base64_encoded(mock_print):
    assert main.handler(
        {
            "body": "eyJjc3AtcmVwb3J0IjogeyJiYW0iOiAiYmF6In19Cg==",
            "isBase64Encoded": "1",
        },
        {},
    ) == {"status": "ok"}
    mock_print.assert_called_with('{"csp-report": {"bam": "baz"}}\n')
