FROM ghcr.io/cloudquery/cloudquery:3.16@sha256:6c9c11e8ce97b22ca2f78ff7c2bc90b23d75ea3c4f868586d3a6325160aaa257

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]