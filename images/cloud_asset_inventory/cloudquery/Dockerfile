FROM ghcr.io/cloudquery/cloudquery:latest@sha256:7fac67fd0d9a30aa966993d813107b6e862a8820da16fac54f7be52c837a3afc

COPY config.yml /app
COPY find_denied_permissions.sh /app

CMD [ "sync", "--log-console", "--log-level", "debug","./config.yml"]