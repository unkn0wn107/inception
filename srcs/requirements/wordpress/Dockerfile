# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 15:32:22 by agaley            #+#    #+#              #
#    Updated: 2024/04/16 19:42:51 by agaley           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

ARG EMAIL
ARG INSTALL_DIR

LABEL maintainer=${EMAIL}

EXPOSE 9000

RUN apk add --no-cache curl git php82 php82-fpm php82-phar php82-mbstring \
    php82-openssl php82-mysqli
RUN rm -f /var/cache/apk/*

RUN ln -s /usr/bin/php82 /usr/local/bin/php

RUN addgroup -S php -g 1000 && adduser -u 1000 -D -S -G php php

RUN chown -R php:php /srv && chown -R php:php /var/log/php82

COPY ./conf/zzz.conf /etc/php82/php-fpm.d/zzz.conf

RUN curl -sS https://getcomposer.org/installer | php82 -- --install-dir=/usr/local/bin --filename=composer
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x /usr/local/bin/wp

COPY --chmod=755 tools/run.sh /usr/local/bin/run.sh

VOLUME ${INSTALL_DIR}

USER php

CMD [ "/usr/local/bin/run.sh" ]
