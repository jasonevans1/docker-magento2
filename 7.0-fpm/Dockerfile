#
# FPM, PHP 7.0, Magento 2 compatible container.
#
# Credit to Mark Shust <mark.shust@mageinferno.com> for the basis of this
# Dockerfile in the https://github.com/mageinferno/docker-magento2-php project.
#

FROM php:7.0-fpm

MAINTAINER Nick Jones <nick@nicksays.co.uk>

# Add repositories for ImageMagick PHP7, add key.
RUN echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list
RUN echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E9C74FEEA2098A6E

# Install dependencies
RUN apt-get update \
  && apt-get install -y \
    cron \
    libfreetype6-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libxslt1-dev \
    git \
    sendmail-bin \
    sendmail \
    curl \
    imagemagick \
    php7.0-imagick

# Configure the gd library
RUN docker-php-ext-configure \
  gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

# Install required PHP extensions
RUN docker-php-ext-install \
  gd \
  intl \
  mbstring \
  mcrypt \
  pdo_mysql \
  xsl \
  zip \
  soap \
  bcmath

RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
  && apt-get install -y nodejs

RUN npm install -g grunt-cli

# Install the 2.4 version of xdebug that's compatible with php7
RUN pecl install -o -f xdebug-2.4.0

RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

# RUN DEBIAN_FRONTEND=noninteractive apt-get -y install golang-go
# RUN mkdir /opt/go && export GOPATH=/opt/go && go get github.com/mailhog/mhsendmail

VOLUME /root/.composer/cache

ADD bin/docker-environment /usr/local/bin/
ADD etc/php.ini /usr/local/etc/php/conf.d/zz-magento.ini
ADD etc/mail.ini /usr/local/etc/php/conf.d/zz-mail.ini
ADD etc/php-xdebug.ini /usr/local/etc/php/conf.d/zz-xdebug-settings.ini
ADD etc/php-fpm.conf /usr/local/etc/

ENV PHP_MEMORY_LIMIT 2G
ENV PHP_ENABLE_XDEBUG false
ENV MAGENTO_ROOT /var/www/magento
ENV MAGENTO_RUN_MODE developer
ENV DEBUG false
ENV UPDATE_UID_GID false

ENTRYPOINT ["/usr/local/bin/docker-environment"]
CMD ["php-fpm", "-F"]
