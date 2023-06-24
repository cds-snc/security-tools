FROM ghcr.io/cloudquery/cloudquery:3.5@sha256:5a8a4eb70043a3da5e587bb02187d5d5e4d79a02a7c132cb4bdb0cee83f0cdbd

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]