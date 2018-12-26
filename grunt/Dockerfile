FROM node:8.14.1-jessie
MAINTAINER Jason Evans <jevans@degdigital.com>

RUN apt-get update && apt-get install -y \
        curl \
        git

RUN npm install -g grunt-cli
RUN npm install -g jspm

COPY run-grunt.sh /usr/local/bin/run-grunt.sh
RUN chmod +x /usr/local/bin/run-grunt.sh

COPY run-grunt-export.sh /usr/local/bin/run-grunt-export.sh
RUN chmod +x /usr/local/bin/run-grunt-export.sh

ADD bin/docker-environment /usr/local/bin/

ENV MAGENTO_ROOT /var/www/magento
WORKDIR /var/www/magento

ENTRYPOINT ["/usr/local/bin/docker-environment"]