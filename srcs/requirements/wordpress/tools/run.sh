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
WP_HOME="http://${DOMAIN_NAME}"
WP_SITEURL="http://${DOMAIN_NAME}/wp"
# WP_DEBUG_LOG='/path/to/debug.log'
${WP_SALTS}
EOF

chmod 640 "${INSTALL_DIR}/.env"

cd "${INSTALL_DIR}"

composer install --no-dev

wp core install --url=${DOMAIN_NAME} --title="inception" --admin_user="${WP_ADMIN}" --admin_password="${WP_ADMIN_PASS}" --admin_email="${WP_ADMIN_EMAIL}" --locale="fr_FR" --skip-email

wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASS}" --role="author" || true

exec php-fpm82 -F
