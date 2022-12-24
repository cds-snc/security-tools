FROM mcr.microsoft.com/vscode/devcontainers/python:3.11-buster@sha256:29c398595ead54a9b1c6dff906384b0991109147e590b57429329bbdeba2e82e

ARG USERNAME=vscode

# Install packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends build-essential ca-certificates curl git gnupg2 jq libffi-dev make openssh-client vim zsh \
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