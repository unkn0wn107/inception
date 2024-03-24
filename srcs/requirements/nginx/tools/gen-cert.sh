#!/bin/sh
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    gen-cert.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 12:03:18 by agaley            #+#    #+#              #
#    Updated: 2024/03/24 15:18:39 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

KEY_FILE="${CERT_DIR}/${DOMAIN_NAME}.key"
CRT_FILE="${CERT_DIR}/${DOMAIN_NAME}.crt"

if [ ! -f "$KEY_FILE" ] || [ ! -f "$CRT_FILE" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CRT_FILE" \
        -subj "/C=FR/ST=Rhône-Alpes/L=Lyon/O=42/CN=${DOMAIN_NAME}"
fi
