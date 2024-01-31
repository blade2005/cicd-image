#!/bin/bash -e
echo $PATH
set -x
poetry --version
aws --version
docker-compose --version
pyenv --version
python --version
task --version
pipx --version
pre-commit --version
npm version
sam --version
docker --version
type -t nvm
type -t npx
set +x
echo 'nvm --version'
nvm --version