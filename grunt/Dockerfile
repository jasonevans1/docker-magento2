FROM php
MAINTAINER Jason Evans <jevans@degdigital.com>

RUN apt-get update && apt-get install -y \
        curl

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
  && apt-get install -y nodejs

RUN npm install -g grunt-cli

COPY run-grunt.sh /usr/local/bin/run-grunt.sh
RUN chmod +x /usr/local/bin/run-grunt.sh
WORKDIR /var/www/magento