"""
Log csp-reports
"""

def handler(event, context):
    print(f"Received request: {event}")
    if "body" in event and "csp-report" in event["body"]:
        print(event["body"])
    return {"status": "ok"}
