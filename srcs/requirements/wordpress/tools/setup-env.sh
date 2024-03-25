#!/bin/sh

set -eux

WP_SALTS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)

cat << EOF > "${INSTALL_DIR}/.env"
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASS}"
# DB_HOST='localhost'
# DB_PREFIX='wp_'
WP_ENV='development'
WP_HOME="${DOMAIN_NAME}"
# WP_SITEURL="\${WP_HOME}/wp"
# WP_DEBUG_LOG='/path/to/debug.log'
$WP_SALTS
EOF

chmod 640 "${INSTALL_DIR}/.env"

echo "WordPress env setup done"
