#!/bin/bash

set -e

if [ ! -d /vols/src ]; then
  echo "No /vols/src with code"
  exit 1
fi

function git_config {
  git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf git@github.com:
}

git_config

rsync -arv --exclude=node_modules --delete-after /vols/src/ ./

npm install
gulp build

exec gulp watch
