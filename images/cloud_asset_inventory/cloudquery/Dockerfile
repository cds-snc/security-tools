FROM ghcr.io/cloudquery/cloudquery:3.21@sha256:d39c01dd64a24539bd2eac1f19d3e3bd29d188366a02ce57a2448369f11e5728

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]