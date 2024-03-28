FROM ghcr.io/cloudquery/cloudquery:latest

RUN apk add --no-cache sqlite

ARG CONFIG_FILE=config.yml
COPY ${CONFIG_FILE} /app/config.yml

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]
