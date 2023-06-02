FROM ghcr.io/cloudquery/cloudquery:3.5@sha256:37a3b6e2c0aa1fe64b5b84bf0a252ff704e52d2835074bc2941c11f7f0be5d75

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]