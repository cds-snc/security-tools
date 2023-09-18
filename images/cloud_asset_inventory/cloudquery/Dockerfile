FROM ghcr.io/cloudquery/cloudquery:3.17@sha256:961d8ff0027929fa1f9e05cdbce92f6bacaddab429b413394c545fd21d78f19f

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]