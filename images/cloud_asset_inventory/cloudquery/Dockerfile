FROM ghcr.io/cloudquery/cloudquery:3.2@sha256:19b437fdb5a65b79c8e085e3de9ba8e5dc9349018977b543c8062b01e364f5e1

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]