FROM ghcr.io/cloudquery/cloudquery:3.17@sha256:a8a1a07acb4287eda9fe637bbad426cb135daa0c026a9b6bb501c2ed331cefea

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]