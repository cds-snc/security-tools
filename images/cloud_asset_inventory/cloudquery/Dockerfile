FROM debian:bullseye@sha256:ad47d883924a75f704037e49c71c20ef209fb3ba05be7070322cb45d2e089261

# Set the working directory
WORKDIR /app

# Copy dependencies file
COPY ./dependencies.txt .

# Install dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
  xargs -a ./dependencies.txt apt-get install -y && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean && \
  rm dependencies.txt

# Set the version
ARG TOOL=cli-v5.13.1
ARG DISTRIBUTION=cloudquery_linux_amd64

# Download the CloudQuery CLI
COPY ./get_cloudquery.sh .
RUN ./get_cloudquery.sh ${TOOL} ${DISTRIBUTION} && \
  mv cloudquery /usr/local/bin/cloudquery && \
  chmod +x /usr/local/bin/cloudquery && \
  rm get_cloudquery.sh

# Set the API key as an environment variable
ARG CLOUDQUERY_API_KEY
ENV CLOUDQUERY_API_KEY=${CLOUDQUERY_API_KEY}

# Set the S3 bucket variable
ARG CQ_S3_BUCKET
ENV CQ_S3_BUCKET=${CQ_S3_BUCKET}

# Copy the config file and install the plugins (requires the API key)
ARG CONFIG_FILE=./config.yml
COPY ${CONFIG_FILE} ./config.yml
RUN cloudquery plugin install config.yml

CMD [ "sync", "--log-console", "--log-level", "debug","config.yml"]