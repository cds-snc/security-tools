FROM python:3.10.0-slim

RUN  apt-get update \
  && apt-get install -y wget unzip\
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Set build variables
ARG git_sha
ENV GIT_SHA=$git_sha

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Install AWS cli
ARG AWS_CLI_VERSION="2.4.5"
RUN wget -O awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip \
 && unzip awscliv2.zip \
 && aws/install \
 && rm -rf \
    awscliv2.zip \
    aws \
    /usr/local/aws-cli/v2/*/dist/aws_completer \
    /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
    /usr/local/aws-cli/v2/*/dist/awscli/examples

COPY . .

COPY bin/entry.sh /app/entry.sh

RUN chmod 755 /app/entry.sh

EXPOSE 8000

ENTRYPOINT [ "/app/entry.sh" ]