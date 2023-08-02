FROM ghcr.io/cloudquery/cloudquery:3.12@sha256:da31051d2fedda278b4dbd99addaa3a59615ab3d517210880863ca9867d84e5c

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]