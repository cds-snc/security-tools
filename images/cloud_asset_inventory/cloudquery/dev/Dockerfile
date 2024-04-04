FROM mcr.microsoft.com/devcontainers/go:1-1.22-bookworm

# Set the working directory
WORKDIR /app

# Copy dependencies file
COPY ./dependencies.txt .

# Install dependencies
RUN apt-get update && \
  xargs -a ./dependencies.txt apt-get install -y && \
  rm -rf /var/lib/apt/lists/*

# Download and install CloudQuery
RUN curl -L https://github.com/cloudquery/cloudquery/releases/download/cli-v5.13.0/cloudquery_linux_amd64 -o cloudquery
RUN chmod a+x cloudquery
RUN mv cloudquery /usr/local/bin/

# Accept the API key as a build argument
ARG CLOUDQUERY_API_KEY

# Set the API key as an environment variable
ENV CLOUDQUERY_API_KEY=${CLOUDQUERY_API_KEY}

# Copy the config file and install the plugins (requires the API key)
ARG CONFIG_FILE=./config.yml
COPY ${CONFIG_FILE} ./config.yml
RUN cloudquery plugin install config.yml

# Copy the psql.sh file and make it executable
COPY psql.sh ./psql.sh
RUN chmod +x ./psql.sh

# Copy the log_connections.sh file and make it executable
COPY ./log_connections.sh /usr/local/bin/log_connections.sh
RUN chmod +x /usr/local/bin/log_connections.sh