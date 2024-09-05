# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 11:53:02 by agaley            #+#    #+#              #
#    Updated: 2024/09/02 15:10:28 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.19

ARG EMAIL
ARG CERT_DIR

LABEL maintainer=${EMAIL}

EXPOSE 443

RUN apk add --no-cache nginx openssl shadow
RUN rm -f /var/cache/apk/*

RUN usermod -u 1000 nginx && groupmod -g 1000 nginx
RUN chown -R nginx:nginx /run/nginx /etc/nginx /var/lib/nginx /var/log/nginx

RUN mkdir -p ${CERT_DIR} && chmod 755 ${CERT_DIR} && chown nginx:nginx ${CERT_DIR}
COPY --chmod=755 tools/run.sh /usr/local/bin/run.sh

USER nginx

RUN rm /etc/nginx/http.d/default.conf
COPY conf/custom.conf /etc/nginx/http.d/custom.conf
COPY conf/wordpress.conf /etc/nginx/http.d/wordpress.conf

CMD ["/usr/local/bin/run.sh"]
