#!/bin/bash
mkdir -p /var/www/.npm
chown www-data:www-data /var/www/.npm/
mkdir -p /var/www/.jspm
chown www-data:www-data /var/www/.jspm/
cd /var/www/magento/ui
su -s /bin/sh www-data -c "/usr/local/bin/npm install"
su -s /bin/sh www-data -c "/usr/local/bin/jspm install -y"
su -s /bin/sh www-data -c "/usr/local/bin/grunt export"