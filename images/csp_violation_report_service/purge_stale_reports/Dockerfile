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

# Install the runtime interface client
RUN pip install awslambdaric

COPY . .

# Install lambda runtime interactive environment
ARG RIE_VERSION=1.1
ARG AWS_RIE_SRC=https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download
RUN wget -O aws-lambda-rie ${AWS_RIE_SRC}/${RIE_VERSION}/aws-lambda-rie \
    && mv aws-lambda-rie /usr/local/bin/aws-lambda-rie

RUN chmod 755 /usr/local/bin/aws-lambda-rie 

COPY bin/entry.sh /app/entry.sh

RUN chmod 755 /app/entry.sh

ENTRYPOINT [ "/app/entry.sh" ]
CMD [ "lambda.handler" ]