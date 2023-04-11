FROM mcr.microsoft.com/vscode/devcontainers/python:3.11-buster@sha256:faa93484c50e765db59d824c4b687196fdaeba22b001edf358962a7edbb6b8d2

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