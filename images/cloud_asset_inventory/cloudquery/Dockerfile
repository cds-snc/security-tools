FROM ghcr.io/cloudquery/cloudquery:3.5@sha256:74e14a8714b6341ecc316955549066bbcac227abb6ca3c828c0ba3f7644c74d9

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]