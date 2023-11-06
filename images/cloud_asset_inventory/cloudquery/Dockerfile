FROM ghcr.io/cloudquery/cloudquery:3.27@sha256:08473ee0b5e840a02babe1e75c203294624e31c0fef7fcdce753c9d14097cfe9

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]