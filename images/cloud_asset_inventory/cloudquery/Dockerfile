FROM ghcr.io/cloudquery/cloudquery:3.29@sha256:601ee4a584ad5da24d9a8bce1f6e8db64f071fb0df9fc5819db1e71a1aef933c

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]