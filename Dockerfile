# vim:set ft=dockerfile:
FROM alpine:3.6

MAINTAINER Andrius Kairiukstis <andrius@kairiukstis.com>

ADD mysql-connector-odbc-5.3.13-linux-glibc2.12-x86-32bit.tar.gz /tmp/mysql-connector-odbc-5.3.13-linux-glibc2.12-x86-32bit.tar.gz

#RUN apk add --update less psqlodbc asterisk-odbc asterisk-pgsql asterisk-sounds-en \
#RUN apk add --update asterisk-cdr-mysql \
#&&  rm -rf /var/cache/apk/*

RUN apk add --update asterisk-cdr-mysql psqlodbc asterisk-odbc \
&&  apk add mysql-connector-odbc --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
&&  rm -rf /var/cache/apk/*

RUN apk add --update \
      asterisk \
      asterisk-sample-config \
&& rm -rf /usr/lib/asterisk/modules/*pjsip* \
&& asterisk -U asterisk \
&& sleep 5 \
&& pkill -9 asterisk \
&& pkill -9 astcanary \
&& sleep 2 \
&& rm -rf /var/run/asterisk/* \
&& mkdir -p /var/spool/asterisk/fax \
&& chown -R asterisk: /var/spool/asterisk/fax \
&& truncate -s 0 /var/log/asterisk/messages \
                 /var/log/asterisk/queue_log \
&&  rm -rf /var/cache/apk/* \
           /tmp/* \
           /var/tmp/*

EXPOSE 5060/udp 5060/tcp
VOLUME /var/lib/asterisk/sounds /var/lib/asterisk/keys /var/lib/asterisk/phoneprov /var/spool/asterisk /var/log/asterisk

ADD docker-entrypoint.sh /docker-entrypoint.sh

#ENTRYPOINT ["/docker-entrypoint.sh"]
ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
