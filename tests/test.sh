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
sam --version
docker --version
type -t nvm
type -t npx
npm version
set +x
echo 'nvm --version'
nvm --version