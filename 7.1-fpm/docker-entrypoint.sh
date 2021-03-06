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

# Configure PHP-FPM
[ ! -z "${MAGENTO_RUN_MODE}" ] && sed -i "s/!MAGENTO_RUN_MODE!/${MAGENTO_RUN_MODE}/" /usr/local/etc/php-fpm.conf

exec "$@"
