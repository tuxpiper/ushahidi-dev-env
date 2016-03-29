#!/bin/bash

set -e

if [ ! -d /vols/src ]; then
  echo "No /vols/src with code"
  exit 1
fi

rsync -arv --exclude=node_modules --delete-after /vols/src/ ./

npm install
gulp build

exec gulp watch
