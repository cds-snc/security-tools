FROM ghcr.io/cloudquery/cloudquery:3.21@sha256:e0cfaf0af906eaf25e4aa6a3ee5391a4cae47723b3e6de1ca4666fbaa5c7ac5c

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]