FROM ghcr.io/cloudquery/cloudquery:3.29@sha256:db5ca5fcf0db8067630f8c52e8adc72411532a659e2d96da390f72781fc148b8

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]