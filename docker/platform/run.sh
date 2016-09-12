#!/bin/bash

function join { local IFS="$1"; shift; echo "$*"; }

function sync {
  if [ ! -d /vols/src ]; then
    echo "No /vols/src with the code"
    exit 1
  fi
  rsync -rlptDv --exclude=vendor --exclude=.git --exclude=bin/phinx --delete-during /vols/src/ /var/www/
  chown -R www-data:www-data /var/www
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
  su -s /bin/bash www-data <<EOF
set -e
cd /var/www
./bin/update --no-interaction
./bin/phinx migrate -c application/phinx.php
EOF
}

set -ex

run() {
  sync;
  write_env;
  wait_mysql;
  update;
  #
  case "$SERVER_FLAVOR" in
    apache2)
      setup_apache
      ;;
    nginx)
      setup_fpm
      setup_nginx
      ;;
    *)
      echo "Unknown server flavor! $SERVER_FLAVOR"
      exit 1
      ;;
  esac
  # Setup cron and supervisor
  setup_cron
  setup_supervisord
  # Start supervisor
  exec supervisord -n -c /etc/supervisor/supervisord.conf
}


setup_fpm() {
  cat > /etc/supervisor/conf.d/php-fpm <<EOF
[program:phpfpm]
autorestart=false  
command=/usr/local/sbin/php-fpm
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
stderr_logfile=/dev/fd/2
stderr_logfile_maxbytes=0
EOF
}

setup_nginx() {
  cp /dist/nginx.conf /etc/nginx/nginx.conf
  cp /dist/fastcgi_params.conf /etc/nginx/fastcgi_params.conf
  cp /dist/nginx-site.conf /etc/nginx/sites-available/default
  cat > /etc/nginx/conf.d/upstream.conf << EOF
upstream web_backend {
  server ${WEB_HOST}:${WEB_PORT};
}
EOF
  cat > /etc/supervisor/conf.d/nginx <<EOF
[program:nginx]
autorestart=false  
command=/usr/sbin/nginx -g "daemon off;"  
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
stderr_logfile=/dev/fd/2
stderr_logfile_maxbytes=0
EOF
}

setup_cron() {
  ## Install crontab
  local cron_file=$(tempfile)
  touch /var/log/cronjobs.out
  chmod 777 /var/log/cronjobs.out
  cat > ${cron_file} <<EOF
PATH=/usr/local/bin:/usr/bin:/bin
SHELL=/bin/bash
*/5 * * * * cd /var/www/html/platform && ./bin/ushahidi dataprovider outgoing 2>&1 >> /var/log/cronjobs.out
*/5 * * * * cd /var/www/html/platform && ./bin/ushahidi dataprovider incoming 2>&1 >> /var/log/cronjobs.out
*/5 * * * * cd /var/www/html/platform && ./bin/ushahidi savedsearch 2>&1 >> /var/log/cronjobs.out
*/5 * * * * cd /var/www/html/platform && ./bin/ushahidi notification queue 2>&1 >> /var/log/cronjobs.out
EOF
  crontab -u www-data ${cron_file}
  rm -f ${cron_file}
  #
  cat > /etc/supervisor/conf.d/cron <<EOF
[program:cron]
autorestart=false  
command=cron -f

[program:tail-cron]
autorestart=false
command=tail -f /var/log/cronjobs.out
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
stderr_logfile=/dev/fd/2
stderr_logfile_maxbytes=0
EOF
}

setup_supervisord() {
  cat > /etc/supervisor/supervisord.conf <<EOF
[supervisord]
nodaemon=true  
logfile = /var/log/supervisord.log  
logfile_maxbytes = 50MB  
logfile_backups=10

[include]
files = conf.d/*
EOF
}

case "$1" in
  bash)
    shift 1;
    exec /bin/bash $*
    ;;
  run)
    run ;;
  *)
    run ;;
esac

