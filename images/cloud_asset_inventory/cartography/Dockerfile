FROM python:3.10.4-alpine3.15

RUN /usr/sbin/adduser -g python -D python
RUN apk add jq curl

RUN mkdir -p /config
WORKDIR /config

COPY --chown=python:python docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
RUN chown -R python:python /config

USER python
RUN /usr/local/bin/python -m venv /home/python/venv
ENV PATH="/home/python/venv/bin:${PATH}" \
    PYTHONUNBUFFERED="1"

COPY --chown=python:python requirements.txt /home/python/cartography/requirements.txt
RUN /home/python/venv/bin/pip install --no-cache-dir --requirement /home/python/cartography/requirements.txt

ENTRYPOINT ["/docker-entrypoint.sh"]