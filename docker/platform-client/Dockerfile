FROM node:5

RUN apt-get update && apt-get install -y rsync && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG GITHUB_TOKEN
RUN git config --global url."https://${GITHUB_TOKEN}@github.com/".insteadOf git@github.com:

RUN npm install -g gulp@3.9.0 gulp-notify@2.2.0 grunt-cli@0.1.13

WORKDIR /var/app
ENV ROOT_BUILD true
COPY package.json /var/app
RUN npm install

COPY run.sh /run.sh

VOLUME /var/app/server/www

CMD [ "/bin/bash", "/run.sh" ]
