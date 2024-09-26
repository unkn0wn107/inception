#!/bin/sh

set -eux

sed -e "s|\${DOMAIN_NAME}|$DOMAIN_NAME|g" \
    -e "s|\${CERT_DIR}|$CERT_DIR|g" \
    /etc/nginx/http.d/wordpress.conf > /etc/nginx/http.d/wordpress.conf.processed

mv /etc/nginx/http.d/wordpress.conf.processed /etc/nginx/http.d/wordpress.conf

KEY_FILE="${CERT_DIR}/${DOMAIN_NAME}.key"
CRT_FILE="${CERT_DIR}/${DOMAIN_NAME}.crt"

if [ ! -f "${KEY_FILE}" ] || [ ! -f "${CRT_FILE}" ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
		-keyout "${KEY_FILE}" \
		-out "${CRT_FILE}" \
		-subj "/C=FR/ST=Rhône-Alpes/L=Lyon/O=42/CN=${DOMAIN_NAME}"
fi

nginx -g "daemon off;"
