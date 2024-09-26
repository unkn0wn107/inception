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
WP_ENV='development'
WP_DEBUG=true
WP_DEBUG_LOG='/var/www/html/wp-content/debug.log'
WP_DEBUG_DISPLAY=true
WP_HOME="https://${DOMAIN_NAME}:8443"
WP_SITEURL="https://${DOMAIN_NAME}:8443/wp"
REDIS_HOST="${REDIS_HOST}"
REDIS_PORT=6379
REDIS_PASSWORD="${REDIS_PASS}"
REDIS_DATABASE=0
WP_CACHE=true
${WP_SALTS}
EOF

chmod 640 "${INSTALL_DIR}/.env"

cd "${INSTALL_DIR}"

composer install --no-dev

# Install WP Redis package
composer require wpackagist-plugin/redis-cache

# Modify wp-config.php to load Redis configuration
sed -i "/Config::apply();/i \
Config::define('WP_REDIS_HOST', env('REDIS_HOST')); \
Config::define('WP_REDIS_PORT', env('REDIS_PORT')); \
Config::define('WP_REDIS_PASSWORD', env('REDIS_PASSWORD')); \
Config::define('WP_REDIS_DATABASE', env('REDIS_DATABASE')); \
Config::define('WP_CACHE', env('WP_CACHE')); \
Config::define('SMTP_HOST', env('SMTP_HOST') ?: 'mailhog'); \
Config::define('SMTP_PORT', env('SMTP_PORT') ?: 1025); \
Config::define('SMTP_AUTH', env('SMTP_AUTH') ?: false); \
Config::define('SMTP_SECURE', env('SMTP_SECURE') ?: '');" "${INSTALL_DIR}/config/application.php"

wp core install --url=${DOMAIN_NAME}:8443 --title="inception" --admin_user="${WP_ADMIN}" --admin_password="${WP_ADMIN_PASS}" --admin_email="${WP_ADMIN_EMAIL}" --locale="fr_FR" --skip-email

wp user create "${WP_USER}" "${WP_USER_EMAIL}" --user_pass="${WP_USER_PASS}" --role="author" || true

wp plugin activate redis-cache
wp redis enable

# Add custom SMTP configuration function
cat <<EOF > "${INSTALL_DIR}/web/app/mu-plugins/custom-smtp.php"
<?php
add_action( 'phpmailer_init', 'custom_phpmailer_init' );
function custom_phpmailer_init( \$phpmailer ) {
    \$phpmailer->isSMTP();
    \$phpmailer->Host = SMTP_HOST;
    \$phpmailer->Port = SMTP_PORT;
    \$phpmailer->SMTPAuth = SMTP_AUTH;
    \$phpmailer->SMTPSecure = SMTP_SECURE;
}
EOF

exec php-fpm82 -F
