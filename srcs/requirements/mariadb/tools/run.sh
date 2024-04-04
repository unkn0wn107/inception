#!/bin/sh

set -ux

mariadbd --bootstrap --skip-grant-tables=0 --datadir=/var/lib/mysql <<EOF
DROP DATABASE IF EXISTS test;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

exec mariadbd -v --user=mysql --console
