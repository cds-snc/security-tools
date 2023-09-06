ARG BASE_IMAGE="python:3.11.2-alpine3.16@sha256:beae3986f2c26f415a02664d03e2a7780ae4b521da8309cbfe80ff2d30fa44c7"
FROM ${BASE_IMAGE} as builder

ARG RIE_VERSION="v1.14"

RUN apk add --no-cache \
    autoconf \
    automake \
    build-base \
    gcc \
    libc-dev \
    libcurl \
    libexecinfo-dev \
    libstdc++ \
    libtool \
    make \
    cmake \
    python3-dev \
    wget

RUN wget https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/${RIE_VERSION}/aws-lambda-rie

RUN mkdir -p /pymodules \
    && pip install awslambdaric --target /pymodules

# Lambda API image
FROM ${BASE_IMAGE} as lambda

COPY --from=builder /pymodules /pymodules
COPY --from=builder /aws-lambda-rie /usr/bin/aws-lambda-rie

# Build variables
ARG FUNCTION_DIR="/function"
ARG GIT_SHA
ENV GIT_SHA=$GIT_SHA
ENV PYTHONPATH="/pymodules"

RUN apk upgrade --no-cache \
    && apk add --no-cache \
    binutils \
    libstdc++

COPY bin/entry.sh /
RUN chmod 555 /usr/bin/aws-lambda-rie /entry.sh

# Copy function code
WORKDIR ${FUNCTION_DIR}
COPY main.py ${FUNCTION_DIR}

ENTRYPOINT [ "/entry.sh", "main.handler" ]
