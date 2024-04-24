# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 11:53:02 by agaley            #+#    #+#              #
#    Updated: 2024/04/24 17:42:40 by agaley           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

ARG EMAIL
ARG CERT_DIR

LABEL maintainer=${EMAIL}

EXPOSE 443

RUN apk --update add --no-cache git patch build-base pcre-dev zlib-dev openssl-dev openssl shadow && rm -f /var/cache/apk/* && cd /tmp && \
    git clone --depth 1 --branch v0.0.6 https://github.com/chobits/ngx_http_proxy_connect_module && \
    wget http://nginx.org/download/nginx-1.25.5.tar.gz && \
    cd /tmp && tar -xzvf nginx-1.25.5.tar.gz && rm nginx-1.25.5.tar.gz && \
    cd nginx-1.25.5/ && patch -p1 < /tmp/ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch && \
    ./configure --sbin-path=/usr/local/sbin/nginx \
        --with-http_ssl_module \
	--with-http_v2_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --add-module=/tmp/ngx_http_proxy_connect_module && \
    make && make install

RUN groupadd -g 1000 nginx && useradd -u 1000 -g 1000 nginx && \
    mkdir -p /run/nginx /etc/nginx /var/lib/nginx /var/log/nginx && \
    chown -R nginx:nginx /run/nginx /etc/nginx /var/lib/nginx /var/log/nginx

RUN mkdir -p ${CERT_DIR} && chmod 755 ${CERT_DIR} && chown nginx:nginx ${CERT_DIR}
COPY --chmod=755 tools/run.sh /usr/local/bin/run.sh

RUN apk add unbound

RUN rm /etc/nginx/conf/nginx.conf
COPY --chown=nginx:nginx conf/custom.conf /etc/nginx/conf/nginx.conf
COPY --chown=nginx:nginx conf/wordpress.conf /etc/nginx/http.d/wordpress.conf

CMD ["/usr/local/bin/run.sh"]
