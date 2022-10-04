FROM python:3.9.7-alpine3.14@sha256:a31add3a2442bceecb9d4f66e575072c4d4a1c7e561b7fe44cdf0dd277685276

ENV PYTHONPATH "${PYTHONPATH}:/opt/python/lib/python3.9/site-packages"
# Setup app user
RUN addgroup --gid 11111 --system app
RUN adduser --shell /bin/false --uid 11111 --ingroup app --system app

# Install dependencies
COPY src/requirements.txt /tmp/
RUN python -m pip install --upgrade pip
RUN pip3 install --upgrade -r /tmp/requirements.txt
RUN apk add bash

# Add libraries
WORKDIR /app/
COPY src/queries.json .
COPY src/neo4j_connector.py /app/
COPY src/neo4j_to_sentinel.py /app/
COPY connector.zip /tmp/
RUN chmod +x /app/neo4j_connector.py /app/neo4j_to_sentinel.py

# Sentinel connector layer
RUN unzip /tmp/connector.zip -d /opt && rm /tmp/connector.zip

# Entrypoint
RUN chown -R app:app /app/
USER app
CMD ["python3", "/app/neo4j_to_sentinel.py"]
