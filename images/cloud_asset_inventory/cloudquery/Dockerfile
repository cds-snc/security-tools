FROM ghcr.io/cloudquery/cloudquery:3.28@sha256:7e090fbfe313dd81350f727b6e428b05a1a2a836982ba572027383b6f848d9f5

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]