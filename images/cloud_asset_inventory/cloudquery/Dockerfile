FROM ghcr.io/cloudquery/cloudquery:3.0@sha256:82f55cc0faa3a6fa880423759341d348446434c04b00da571784782f7748bce9

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]