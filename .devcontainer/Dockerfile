FROM mcr.microsoft.com/vscode/devcontainers/python:3.10-buster@sha256:5df4301ce7f53ad0c1d4378352d9796cd996adedf232fc28aeb4e7ba2d0e02de

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