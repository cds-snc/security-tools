FROM ghcr.io/cloudquery/cloudquery:3.5@sha256:fa1bc47ca70ea69c674fb5e18aab59684f09f98ca182767a06d83ddbbb873421

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]