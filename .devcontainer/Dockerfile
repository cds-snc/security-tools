FROM mcr.microsoft.com/vscode/devcontainers/python:3.11-buster@sha256:1e6060d9af22870314d894f33e1fc7d601adbac243f3b9d8fed57f9eebab0c21

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