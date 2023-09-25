FROM ghcr.io/cloudquery/cloudquery:3.19@sha256:d6357458680be9649edf4e5afc96f44216f537f38f402320a9e9a2e814c6e1d7

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]