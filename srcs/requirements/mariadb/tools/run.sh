#!/bin/ash

set -eux

sql=/usr/bin/seed.sql

touch "${sql}"

cat << EOF > "${sql}"
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASS}' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${DB_ROOT_PASS}');
DROP DATABASE IF EXISTS test;
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
FLUSH PRIVILEGES;
EOF

mysqld --user=mysql < "${sql}"

rm -f "${sql}"

mysqld --user=mysql --console
