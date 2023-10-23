FROM ghcr.io/cloudquery/cloudquery:3.25@sha256:76947b311db69a3ff34d5d4514f16ccb26dd1b3d05a69c2afd6b79556d6b8f12

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]