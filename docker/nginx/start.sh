#!/bin/sh

set -ex

cat > /etc/nginx/conf.d/upstream.conf << EOF
upstream api_backend {
	server ${API_HOST}:${API_PORT};
}
upstream web_backend {
  server ${WEB_HOST}:${WEB_PORT};
}
EOF

exec /usr/sbin/nginx -g 'daemon off;'
