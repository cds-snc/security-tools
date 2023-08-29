FROM ghcr.io/cloudquery/cloudquery:3.14@sha256:80842570c8be344ca19b030ec5765744354dbaef3902b220341a9b0956c95f16

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]