#!/bin/bash

function join { local IFS="$1"; shift; echo "$*"; }

function sync {
  if [ ! -d /vols/src ]; then
    echo "No /vols/src with the code"
    exit 1
  fi
  ls /var/www/bin/
  rsync -arv --exclude=vendor --exclude=.git --exclude=bin/phinx --delete-during /vols/src/ /var/www/
}

function write_env {
  cat > /var/www/.env <<EOF
  DB_HOST=${MYSQL_HOST:-mysql}
  DB_NAME=${MYSQL_DATABASE:-ushahidi}
  DB_USER=${MYSQL_USER:-ushahidi}
  DB_PASS=${MYSQL_PASSWORD:-ushahidi}
  DB_TYPE=MySQLi
EOF
}

function wait_mysql {
  # Wait until MySQL is up
  echo -n "Checking MySQL on ${MYSQL_HOST}"
  k=1; while [ "$k" -lt "60" ]; do
    if nc -z ${MYSQL_HOST} 3306 > /dev/null ; then
      return 0;
    fi
    echo "."
    sleep 1;
    k=$((k + 1))
  done
  echo -n "ERROR unable to contact MySQL"
  return 1;
  echo
}

function update {
  cd /var/www
  export PATH=$PATH:$(join : $(find `pwd`/vendor -name bin))
  echo "PATH is $PATH"
  ./bin/update --no-interaction
}

function run_fpm {
  exec /usr/bin/php-fpm -O -R -F -y /root/docker/php-fpm.conf
}

function start {
  sync;
  write_env;
  wait_mysql;
  update;
  run_fpm;
}

set -e

case "$1" in
  bash)
    shift 1;
    exec /bin/bash $*
    ;;
  start) start ;;
  *) start ;;
esac
