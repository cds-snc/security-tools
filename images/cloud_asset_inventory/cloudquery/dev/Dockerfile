FROM mcr.microsoft.com/devcontainers/go:1-1.22-bookworm

# Set the working directory
WORKDIR /app

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
  postgresql-client \
  && rm -rf /var/lib/apt/lists/*

# Download and install CloudQuery
RUN curl -L https://github.com/cloudquery/cloudquery/releases/download/cli-v5.13.0/cloudquery_linux_amd64 -o cloudquery
RUN chmod a+x cloudquery
RUN mv cloudquery /usr/local/bin/

# Accept the API key as a build argument
ARG CLOUDQUERY_API_KEY

# Set the API key as an environment variable
ENV CLOUDQUERY_API_KEY=${CLOUDQUERY_API_KEY}

# Copy the config file
ARG CONFIG_FILE=cloudquery/config.yml
COPY ${CONFIG_FILE} ./config.yml
# RUN cloudquery login
RUN cloudquery plugin install config.yml
