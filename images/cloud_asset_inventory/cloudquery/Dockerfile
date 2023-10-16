FROM ghcr.io/cloudquery/cloudquery:3.23@sha256:5b8124be09b0d056017f965d2519e1c0e545793f0d70652e2af413acfa6afa31

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]