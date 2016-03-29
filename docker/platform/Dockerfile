FROM alpine:3.3
MAINTAINER David Losada Carballo "davidlosada@ushahidi.com"

RUN apk update && \
    apk add curl php-fpm php-openssl php-gd php-json php-phar php-curl \
                 php-mcrypt php-mysqli php-pdo php-ctype php-dom \
                 php-pdo_mysql php-imap bash rsync && \
    rm -rf /var/cache/apk/*

RUN curl -sS https://getcomposer.org/installer | \
      php -- --install-dir=/usr/local/bin --filename=composer

ARG GITHUB_TOKEN
RUN composer config -g github-oauth.github.com $GITHUB_TOKEN

WORKDIR /var/www
COPY composer.json /var/www/
COPY composer.lock /var/www/
RUN composer install

COPY php-fpm.conf /root/docker/
COPY run.sh /root/docker/
COPY platform.ini /etc/php/conf.d/platform.ini

EXPOSE 9000

ENTRYPOINT [ "/bin/bash", "/root/docker/run.sh" ]
CMD [ "start" ]
