FROM debian:bullseye@sha256:1b1fd1445c1d0ed68123cf76c2d7c7cb47dfdab3df56f7ff9303063110d43291

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

# Copy the config file
ARG CONFIG_FILE=./config.yml
COPY ${CONFIG_FILE} ./config.yml

CMD [ "sync", "--log-console", "--log-level", "debug","config.yml"]