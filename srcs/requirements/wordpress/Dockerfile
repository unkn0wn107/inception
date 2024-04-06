# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 15:32:22 by agaley            #+#    #+#              #
#    Updated: 2024/04/06 03:43:10 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

LABEL maintainer=${EMAIL}

EXPOSE 9000

ARG BR_VERSION
ARG DOMAIN_NAME
ARG INSTALL_DIR
ARG DB_NAME
ARG DB_USER
ARG DB_PASS

RUN apk add --no-cache curl git php82 php82-fpm php82-phar php82-mbstring \
    php82-openssl
RUN rm -f /var/cache/apk/*

RUN addgroup -S php -g 1000 && adduser -u 1000 -D -S -G php php

RUN chown -R php:php /srv && chown -R php:php /var/log/php82

COPY ./conf/zzz.conf /etc/php82/php-fpm.d/zzz.conf

RUN curl -sS https://getcomposer.org/installer | php82 -- --install-dir=/usr/local/bin --filename=composer

RUN git clone --branch ${BR_VERSION} --depth 1 https://github.com/roots/bedrock.git ${INSTALL_DIR}

RUN chown -R php:php ${INSTALL_DIR}
RUN find ${INSTALL_DIR}/web -type d -exec chmod 750 {} \;
RUN find ${INSTALL_DIR}/web -type f -exec chmod 640 {} \;

COPY --chmod=755 tools/setup-env.sh /usr/local/bin/setup-env.sh
RUN /usr/local/bin/setup-env.sh

VOLUME ${INSTALL_DIR}
WORKDIR ${INSTALL_DIR}

USER php

RUN ["php82", "/usr/local/bin/composer", "install", "--no-dev"]

CMD ["php-fpm82", "-F"]
