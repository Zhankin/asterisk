#!/bin/sh

# run as user asterisk by default
ASTERISK_USER=${ASTERISK_USER:-asterisk}
service cron start
if [ "$USERPASS" = "**String**" ]; then
    export USERPASS='production'
fi
echo root:${USERPASS} | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

if [ "$SSH_ENABLE" = "true" ]; then
    service ssh start   
fi

if [ "$1" = "" ]; then
  COMMAND="/usr/sbin/asterisk -T -W -U ${ASTERISK_USER} -p -vvvdddf"
else
  COMMAND="$@"
fi

if [ "${ASTERISK_UID}" != "" ] && [ "${ASTERISK_GID}" != "" ]; then
  # recreate user and group for asterisk
  # if they've sent as env variables (i.e. to macth with host user to fix permissions for mounted folders

  deluser asterisk && \
  adduser --gecos "" --no-create-home --uid ${ASTERISK_UID} --disabled-password ${ASTERISK_USER} \
  || exit
fi

chown -R ${ASTERISK_USER}: /var/log/asterisk \
                           /var/lib/asterisk \
                           /var/run/asterisk \
                           /var/spool/asterisk; \
exec ${COMMAND}
