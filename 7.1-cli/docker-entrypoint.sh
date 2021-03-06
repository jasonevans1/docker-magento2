#!/bin/bash

[ "$DEBUG" = "true" ] && set -x

# Simple mapping from your user/group to a user/group inside the docker.
if [[ "$UPDATE_UID_GID" = "true" ]]; then
    set -e

    UNUSED_USER_ID=21338
    UNUSED_GROUP_ID=21337

    echo "Fixing permissions."

    # Setting Group Permissions
    DOCKER_GROUP_CURRENT_ID=`id -g $DOCKER_GROUP`

    if [ $DOCKER_GROUP_CURRENT_ID -eq $HOST_GROUP_ID ]; then
      echo "Group $DOCKER_GROUP is already mapped to $DOCKER_GROUP_CURRENT_ID. Nice!"
    else
      echo "Check if group with ID $HOST_GROUP_ID already exists"
      DOCKER_GROUP_OLD=`getent group $HOST_GROUP_ID | cut -d: -f1`

      if [ -z "$DOCKER_GROUP_OLD" ]; then
        echo "Group ID is free. Good."
      else
        echo "Group ID is already taken by group: $DOCKER_GROUP_OLD"

        echo "Changing the ID of $DOCKER_GROUP_OLD group to 21337"
        groupmod -o -g $UNUSED_GROUP_ID $DOCKER_GROUP_OLD
      fi

      echo "Changing the ID of $DOCKER_GROUP group to $HOST_GROUP_ID"
      groupmod -o -g $HOST_GROUP_ID $DOCKER_GROUP || true
      echo "Finished"
      echo "-- -- -- -- --"
    fi

    # Setting User Permissions
    DOCKER_USER_CURRENT_ID=`id -u $DOCKER_USER`

    if [ $DOCKER_USER_CURRENT_ID -eq $HOST_USER_ID ]; then
      echo "User $DOCKER_USER is already mapped to $DOCKER_USER_CURRENT_ID. Nice!"

    else
      echo "Check if user with ID $HOST_USER_ID already exists"
      DOCKER_USER_OLD=`getent passwd $HOST_USER_ID | cut -d: -f1`

      if [ -z "$DOCKER_USER_OLD" ]; then
        echo "User ID is free. Good."
      else
        echo "User ID is already taken by user: $DOCKER_USER_OLD"

        echo "Changing the ID of $DOCKER_USER_OLD to 21337"
        usermod -o -u $UNUSED_USER_ID $DOCKER_USER_OLD
      fi

      echo "Changing the ID of $DOCKER_USER user to $HOST_USER_ID"
      usermod -o -u $HOST_USER_ID $DOCKER_USER || true
      echo "Finished"
    fi
    chown -R $DOCKER_USER:$DOCKER_GROUP $MAGENTO_ROOT || true
fi

# Ensure our Magento directory exists
mkdir -p $MAGENTO_ROOT
chown www-data:www-data $MAGENTO_ROOT

CRON_LOG=/var/log/cron.log

# Setup Magento cron
echo "* * * * * www-data /usr/local/bin/php ${MAGENTO_ROOT}/bin/magento cron:run | grep -v \"Ran jobs by schedule\" >> ${MAGENTO_ROOT}/var/log/magento.cron.log" > /etc/cron.d/magento
echo "* * * * * www-data /usr/local/bin/php ${MAGENTO_ROOT}/update/cron.php >> ${MAGENTO_ROOT}/var/log/update.cron.log" >> /etc/cron.d/magento
echo "* * * * * www-data /usr/local/bin/php ${MAGENTO_ROOT}/bin/magento setup:cron:run >> ${MAGENTO_ROOT}/var/log/setup.cron.log" >> /etc/cron.d/magento

# Get rsyslog running for cron output
touch $CRON_LOG
echo "cron.* $CRON_LOG" > /etc/rsyslog.d/cron.conf
service rsyslog start

# Configure Sendmail if required
if [ "$ENABLE_SENDMAIL" == "true" ]; then
    /etc/init.d/sendmail start
fi


# Configure PHP
[ ! -z "${PHP_MEMORY_LIMIT}" ] && sed -i "s/!PHP_MEMORY_LIMIT!/${PHP_MEMORY_LIMIT}/" /usr/local/etc/php/conf.d/zz-magento.ini
[ ! -z "${UPLOAD_MAX_FILESIZE}" ] && sed -i "s/!UPLOAD_MAX_FILESIZE!/${UPLOAD_MAX_FILESIZE}/" /usr/local/etc/php/conf.d/zz-magento.ini

[ "$PHP_ENABLE_XDEBUG" = "true" ] && \
    docker-php-ext-enable xdebug && \
    echo "Xdebug is enabled"

# Configure composer
[ ! -z "${COMPOSER_GITHUB_TOKEN}" ] && \
    composer config --global github-oauth.github.com $COMPOSER_GITHUB_TOKEN

[ ! -z "${COMPOSER_MAGENTO_USERNAME}" ] && \
    composer config --global http-basic.repo.magento.com \
        $COMPOSER_MAGENTO_USERNAME $COMPOSER_MAGENTO_PASSWORD

[ ! -z "${COMPOSER_BITBUCKET_KEY}" ] && [ ! -z "${COMPOSER_BITBUCKET_SECRET}" ] && \
    composer config --global bitbucket-oauth.bitbucket.org $COMPOSER_BITBUCKET_KEY $COMPOSER_BITBUCKET_SECRET

[ ! -z "${COMPOSER_DEG_USERNAME}" ] && \
    composer config --global http-basic.composer.degdarwin.com \
        $COMPOSER_DEG_USERNAME $COMPOSER_DEG_PASSWORD

exec "$@"
