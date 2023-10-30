FROM ghcr.io/cloudquery/cloudquery:3.26@sha256:da11be37cb23e2b457b5c4365cc1d12f623a2907bc452eb7872a10ea4ca15c55

COPY config.yml /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]