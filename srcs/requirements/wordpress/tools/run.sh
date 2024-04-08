#!/bin/sh

set -eux

WP_EXISTS=$(ls -A "${INSTALL_DIR}")

if [ -z "${WP_EXISTS}" ]; then
	git clone --branch "${BR_VERSION}" --depth 1 https://github.com/roots/bedrock.git "${INSTALL_DIR}"
	find "${INSTALL_DIR}"/web -type d -exec chmod 750 {} \;
	find "${INSTALL_DIR}"/web -type f -exec chmod 640 {} \;
fi

WP_SALTS=$(curl https://api.wordpress.org/secret-key/1.1/salt/ | sed "s/define('\(.*\)',\s*'\(.*\)');/\1='\2'/g")

cat <<EOF >"${INSTALL_DIR}/.env"
DB_NAME="${DB_NAME}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASS}"
DB_HOST=mariadb
WP_ENV='production'
WP_HOME="${DOMAIN_NAME}"
WP_SITEURL="${DOMAIN_NAME}/wp"
# WP_DEBUG_LOG='/path/to/debug.log'
${WP_SALTS}
EOF

chmod 640 "${INSTALL_DIR}/.env"

cd "${INSTALL_DIR}"

php82 /usr/local/bin/composer install --no-dev

exec php-fpm82 -F
