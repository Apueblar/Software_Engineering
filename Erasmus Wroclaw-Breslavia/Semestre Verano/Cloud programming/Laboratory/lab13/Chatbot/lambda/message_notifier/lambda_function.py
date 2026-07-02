import json
import os
from datetime import datetime, timezone

import boto3

sns = boto3.client("sns")
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "content-type",
            "Access-Control-Allow-Methods": "OPTIONS,POST",
        },
        "body": json.dumps(body),
    }


def lambda_handler(event, context):
    if event.get("requestContext", {}).get("http", {}).get("method") == "OPTIONS":
        return _response(200, {"ok": True})

    try:
        raw_body = event.get("body") or "{}"
        payload = json.loads(raw_body)

        username = str(payload.get("username", "Anonymous"))
        message = str(payload.get("message", ""))
        timestamp = str(payload.get("timestamp") or datetime.now(timezone.utc).isoformat())

        if not message.strip():
            return _response(400, {"error": "Message cannot be empty"})

        email_body = (
            "A chat message containing the configured Lambda keyword was detected.\n\n"
            f"Username: {username}\n"
            f"Timestamp: {timestamp}\n"
            f"Message: {message}\n"
        )

        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject="Chatbot Lambda notification",
            Message=email_body,
        )

        return _response(200, {"status": "sent"})
    except Exception as exc:
        return _response(500, {"error": str(exc)})
