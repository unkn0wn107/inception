# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 15:32:22 by agaley            #+#    #+#              #
#    Updated: 2024/03/25 02:03:25 by agaley           ###   ########lyon.fr    #
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

RUN apk add --no-cache php82 php82-fpm php82-mysqli php82-json php82-openssl \
    php82-curl php82-zlib php82-xml php82-phar php82-intl php82-dom \
    php82-xmlreader php82-ctype php82-session php82-mbstring php82-gd curl git
RUN rm -f /var/cache/apk/*

# COPY ./conf/www.conf /etc/php82/php-fpm.d/www.conf

RUN curl -sS https://getcomposer.org/installer | php82 -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p ${INSTALL_DIR} && cd /var/www
RUN git clone --branch ${BR_VERSION} --depth 1 https://github.com/roots/bedrock.git wordpress

# RUN chown -R www-data:www-data ${INSTALL_DIR}
RUN find ${INSTALL_DIR} -type d -exec chmod 750 {} \;
RUN find ${INSTALL_DIR} -type f -exec chmod 640 {} \;

COPY tools/setup-env.sh /usr/local/bin/setup-env.sh
RUN chmod +x /usr/local/bin/setup-env.sh
RUN /usr/local/bin/setup-env.sh

VOLUME ${INSTALL_DIR}
WORKDIR ${INSTALL_DIR}

ENTRYPOINT ["php-fpm82", "-F"]
