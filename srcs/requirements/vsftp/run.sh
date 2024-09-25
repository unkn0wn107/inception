#!/bin/sh

set -eux

apk add --no-cache shadow

if ! id -u "${FTP_USER}" >/dev/null 2>&1; then
    adduser -D "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASS}" | chpasswd
fi

usermod -d /srv/wordpress "${FTP_USER}"

# Update vsftpd.conf with environment variables
sed -i "s/^listen_port=.*/listen_port=${FTP_COMMAND_PORT}/" /etc/vsftpd/vsftpd.conf
sed -i "s/^ftp_data_port=.*/ftp_data_port=${FTP_DATA_PORT}/" /etc/vsftpd/vsftpd.conf
sed -i "s/^pasv_min_port=.*/pasv_min_port=${FTP_PASSIVE_PORT_MIN}/" /etc/vsftpd/vsftpd.conf
sed -i "s/^pasv_max_port=.*/pasv_max_port=${FTP_PASSIVE_PORT_MAX}/" /etc/vsftpd/vsftpd.conf

exec vsftpd /etc/vsftpd/vsftpd.conf