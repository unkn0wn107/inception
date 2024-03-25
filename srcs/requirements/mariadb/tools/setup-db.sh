#!/bin/sh

set -eux

sql=$(mktemp)
if [ ! -f "$sql" ]; then
    exit 1
fi

cat << EOF > "$sql"
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$DB_ROOT_PASS' WITH GRANT OPTION;
GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS' WITH GRANT OPTION;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('$DB_ROOT_PASS');
DROP DATABASE IF EXISTS test;
FLUSH PRIVILEGES;
EOF

if [ -n "$DB_NAME" ]; then
    echo "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> "$sql"
    if [ -n "$DB_USER" ] && [ -n "$DB_PASS" ]; then
        echo "GRANT ALL ON \`$DB_NAME\`.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';" >> "$sql"
    fi
fi

/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < "$sql"
rm -f "$sql"

echo 'MySQL init done. Starting up ...'

exec /usr/bin/mysqld --user=mysql --console "$@"
