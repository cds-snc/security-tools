FROM ghcr.io/cloudquery/cloudquery:latest@sha256:ce106c8e46e9e1f2d3341eaee7329b651fba147821008098528ba2f2555940e1

RUN apk add --no-cache sqlite

ARG CONFIG_FILE=config.yml
COPY ${CONFIG_FILE} /app/config.yml

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]
