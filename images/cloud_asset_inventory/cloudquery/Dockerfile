FROM ghcr.io/cloudquery/cloudquery:latest

COPY config.yml /app
COPY find_denied_permissions.sh /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]