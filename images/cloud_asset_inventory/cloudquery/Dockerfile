FROM ghcr.io/cloudquery/cloudquery:3.12@sha256:5c5532cb73363bfd6d6f01cd3cf89b08e65cd5dba143e1c07945a3460ff96c11

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]