from masonite.environment import env


DRIVERS = {
    "slack": {
        "token": env("SLACK_TOKEN", ""),  # used for API mode
        "webhook": env("SLACK_WEBHOOK", ""),  # used for webhook mode
    },
    "database": {
        "connection": "sqlite",
        "table": "notifications",
    },
}

DRY = False
