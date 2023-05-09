FROM ghcr.io/cloudquery/cloudquery:3.2@sha256:b6ad40516396ac81ef374186574decb45fae2454461705a31dcfb89818c3c1e0

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]