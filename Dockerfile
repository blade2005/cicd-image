FROM debian:stable-slim as base

ENV IMAGE_VERSION 0.0.6

ENV DEBIAN_FRONTEND=noninteractive

ENV HOME /root

RUN apt-get update -y
RUN apt-get install -y \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    git \
    unzip \
    ca-certificates

# Task
ENV TASK_VERSION "v3.33.1"

# Pyenv
ENV PYENV_ROOT "/pyenv"
ENV PATH "$PYENV_ROOT/bin:${PYENV_ROOT}/shims:$PATH"
ENV PYENV_GIT_TAG=v2.3.35
ENV PYENV_VERSION 3.11.7

# Pre-commit
ENV PRE_COMMIT_VERSION 3.1.1

# NVM
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 18
ENV NVM_VERSION v0.39.3
ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH "$HOME/.local/bin:$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

# Pyenv
RUN curl -s -o- https://pyenv.run | bash \
    && pyenv install ${PYENV_VERSION} \
    && pyenv global ${PYENV_VERSION} \
    && python --version \
    && pip --version \
    && pip install pipx \
    && pipx ensurepath

# NVM
RUN mkdir $NVM_DIR && \
    curl -s -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default && \
    pipx install git+https://github.com/iamogbz/nvshim.git

# AWS CLI
RUN curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip -q awscliv2.zip && \
    ./aws/install && \
    rm -rf aws awscliv2.zip && \
    aws --version

# Docker
RUN sh -c "$(curl -fsSL https://get.docker.com)" \
    && ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

# Task
RUN sh -c "$(curl -s --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin $TASK_VERSION \
    && task --version

RUN pipx install pre-commit==${PRE_COMMIT_VERSION} \
    && pre-commit --version

RUN curl -sSL https://install.python-poetry.org | python3 - \
    && poetry --version

RUN wget -q https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip \
    && unzip -q aws-sam-cli-linux-x86_64.zip -d sam-installation \
    && ./sam-installation/install \
    && rm -rf sam-installation aws-sam-cli-linux-x86_64.zip

RUN curl --proto '=https' --tlsv1.2 -fsSL https://static.pantsbuild.org/setup/get-pants.sh | bash

FROM scratch
COPY --from=base / /
ENV HOME /root
ENV PYENV_VERSION 3.11.7
ENV PYENV_ROOT "/pyenv"
ENV NVM_DIR /usr/local/nvm
ENV PATH "$HOME/.local/bin:$PYENV_ROOT/bin:${PYENV_ROOT}/shims:$PATH"
SHELL ["/bin/bash", "--login"]
WORKDIR /app