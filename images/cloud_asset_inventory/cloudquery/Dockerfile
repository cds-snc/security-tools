FROM ghcr.io/cloudquery/cloudquery:3.9@sha256:821cecb72513e3b9a50445fc9d17d1cb34ab54855f391d0db41a83eaece57ee2

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]