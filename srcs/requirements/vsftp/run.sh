#!/bin/sh

set -eux

apk add --no-cache shadow

adduser -D ${FTP_USER}
echo "${FTP_USER}:${FTP_PASS}" | chpasswd

usermod -d /srv/wordpress ${FTP_USER}

vsftpd /etc/vsftpd/vsftpd.conf