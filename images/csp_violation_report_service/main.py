"""
Log csp-reports
"""

import base64
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context):
    "Handle the CSP report POST requests"

    logger.debug("Received request: %s", event)
    event_body = event.get("body")

    if event_body:
        # Handle base64 encoded POST body content
        if event.get("isBase64Encoded"):
            event_body = base64.b64decode(event_body).decode("utf-8")

        # Log the csp-report
        if "csp-report" in event_body:
            # print is used so as to only print the raw JSON to CloudWatch logs
            print(event_body)

    return {"status": "ok"}
