# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/25 13:22:16 by agaley            #+#    #+#              #
#    Updated: 2024/03/25 15:06:35 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

LABEL maintainer=${EMAIL}

EXPOSE 8888

RUN ["apk", "add", "--no-cache", "php82", "php82-session", "php82-mysqli", "php82-pdo_mysql", "php82-json", "php82-openssl", "php82-curl", "php82-zlib", "php82-xml", "php82-phar", "php82-intl", "php82-dom", "php82-xmlreader", "php82-ctype", "php82-mbstring", "php82-gd"]
RUN rm -f /var/cache/apk/*

RUN wget "https://github.com/vrana/adminer/releases/download/v${ADMINER_VER}/adminer-${ADMINER_VER}.php" -O /var/www/localhost/htdocs/index.php
RUN echo "server { listen 80; root /var/www/localhost/htdocs; index index.php; location ~ \.php$ { include fastcgi_params; fastcgi_pass 127.0.0.1:9000; fastcgi_index index.php; fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; } }" > /etc/nginx/http.d/default.conf

RUN echo "clear_env = no" >> /etc/php8/php-fpm.d/www.conf

ENTRYPOINT ["php-fpm82", "-F"]
