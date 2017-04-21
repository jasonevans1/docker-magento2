#!/bin/bash
mkdir -p /var/www/.npm
chown www-data:www-data /var/www/.npm/
cd /var/www/magento/ui
su -s /bin/sh www-data -c "/usr/bin/npm install"
su -s /bin/sh www-data -c "/usr/bin/grunt export"