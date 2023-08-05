FROM mcr.microsoft.com/vscode/devcontainers/python:3.11-buster@sha256:cd775b09c0a6f4bbd5012f8a9a3d52f68aa43a626ce2e1afa98f9ead0f66bad0

ARG USERNAME=vscode

# Install packages
COPY .devcontainer/apt-packages.txt ./
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && xargs apt-get -y install --no-install-recommends  <apt-packages.txt \
    && apt-get autoremove -y && apt-get clean -y

# Install Python tools
RUN pip3 install --upgrade requests setuptools \
    && pip3 install --upgrade botocore checkov pipx pip-tools

RUN python3 -m pipx ensurepath && pipx install aws-sso-util
    
# Setup aliases and autocomplete
RUN echo "\n\
complete -C /usr/bin/aws_completer aws\n\
complete -C /usr/local/bin/terraform terraform\n\
complete -C /usr/local/bin/aws_completer aws\n\
alias tf='terraform'\n\
alias tg='terragrunt'\n\
alias ll='la -la'" >> /home/"${USERNAME}"/.zshrc