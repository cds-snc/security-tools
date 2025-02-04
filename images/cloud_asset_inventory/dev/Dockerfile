FROM debian:bullseye@sha256:63904b1442dc0bb1e7a7a7065b3ba0d10d4e300f984115a40d371827fe4e3a85

# Set the working directory
WORKDIR /app

# Copy dependencies file
COPY ./dev/dependencies.txt .

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
COPY ./cloudquery/get_cloudquery.sh .
RUN ./get_cloudquery.sh ${TOOL} ${DISTRIBUTION} && \
  mv cloudquery /usr/local/bin/cloudquery && \
  chmod +x /usr/local/bin/cloudquery && \
  rm get_cloudquery.sh

# Accept the API key as a build argument
ARG CLOUDQUERY_API_KEY
ENV CLOUDQUERY_API_KEY=${CLOUDQUERY_API_KEY}

# Copy the config file and install the plugins (requires the API key)
ARG CONFIG_FILE=./dev/config.yml
COPY ${CONFIG_FILE} ./config.yml
RUN cloudquery plugin install config.yml

# Copy the log_connections.sh file and make it executable
COPY ./dev/log_connections.sh /usr/local/bin/log_connections.sh
RUN chmod +x /usr/local/bin/log_connections.sh