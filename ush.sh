#!/bin/bash

set -e

BASEDIR=$(dirname $0)

default_platform_repo="git@github.com:ushahidi/platform.git"
default_platform_client_repo="git@github.com:ushahidi/platform-client.git"
platform_folder="./"$(echo ${default_platform_repo##*/} | sed -e 's/\.git$//')
platform_client_folder="./"$(echo ${default_platform_client_repo##*/} | sed -e 's/\.git$//')

setup_env() {
  if [ -z "$GITHUB_TOKEN" ]; then
    echo "Please set up a GITHUB_TOKEN environment variable!"
    exit 1
  fi
  cat > $BASEDIR/.env <<EOF
export GITHUB_TOKEN=${GITHUB_TOKEN}
export PLATFORM_DIR=${platform_folder}
export PLATFORM_CLIENT_DIR=${platform_client_folder}
export PORT=${PORT:-8080}
EOF
}

load_env() {
  source $BASEDIR/.env
}

compose() {
  docker-compose $* ;
}

copy_deps() {
  cp $BASEDIR/${platform_folder}/composer.json ${platform_folder}/composer.lock ./docker/platform/
  cp ${platform_client_folder}/package.json ./docker/platform-client/
}

ensure_repos() {
  # Clone the folder
  if [[ ! -d ${platform_folder} || ! -d ${platform_client_folder} ]]; then
    if [ ! -d ${platform_folder} ]; then
      git clone $default_platform_repo $platform_folder
    fi
    if [ ! -d ${platform_client_folder} ]; then
      git clone $default_platform_client_repo $platform_client_folder
    fi
  fi
}


# Setup environment if necessary
if [[ -n "$1" && "$1" != "create" ]]; then
  # Setup env
  if [ ! -f .env ]; then
    setup_env
  fi
  ensure_repos
  load_env
fi

#

check_target() {
  local target=$1
  if [[ $target =~ ^/.* || $target =~ ^\.\./.* ]]; then
    return 0;
  else
    return 1;
  fi
}

#

start() {
  copy_deps
  compose build
  compose up
}

stop() {
  compose stop $*
}

rm() {
  compose stop $*
  compose rm -f $*
}

case "$1" in
  create)
    shift
    target="$1"
    if [ -z "$target" ]; then
      echo "Please specify target folder"
      exit 1
    fi
    if ! check_target $target; then
      echo "Target folder can't be within this script's folder"
      exit 1
    fi
    if [ ! -d $target ]; then
      mkdir -p $target
    fi
    cp -a $BASEDIR/* $target/
    echo "Success"
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    compose stop
    compose up
    ;;
  rm)
    rm
    ;;
  logs)
    shift 1
    compose logs $*
    ;;
  *)
    ;;
esac
