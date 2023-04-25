FROM ghcr.io/cloudquery/cloudquery:3.0@sha256:0e344a64d2af0b287471b8f7901e805d0b28abb6128e871d01ade30b9f8d63ac

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]