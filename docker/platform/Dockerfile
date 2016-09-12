FROM php:5.5.35-fpm

RUN apt-get update && apt-get install -y \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libpng12-dev \
      libmcrypt-dev \
      libc-client2007e-dev \
      libkrb5-dev \
      libcurl4-openssl-dev \
      unzip \
      rsync \
      netcat-openbsd \
      supervisor \
      cron \
      git \
      nginx && \
    docker-php-ext-install curl json mcrypt mysqli pdo pdo_mysql && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sS https://getcomposer.org/installer | \
      php -- --install-dir=/usr/local/bin --filename=composer

ARG GITHUB_TOKEN
RUN composer config -g github-oauth.github.com $GITHUB_TOKEN

WORKDIR /var/www
COPY composer.json /var/www/
COPY composer.lock /var/www/
RUN composer install

#COPY php-fpm.conf /root/docker/
#COPY platform.ini /etc/php/conf.d/platform.ini
COPY run.sh /run.sh
COPY dist/ /dist

ENV SERVER_FLAVOR nginx

EXPOSE 80

ENTRYPOINT [ "/bin/bash", "/run.sh" ]
