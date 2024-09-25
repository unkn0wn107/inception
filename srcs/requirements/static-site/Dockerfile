# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/25 18:14:48 by agaley            #+#    #+#              #
#    Updated: 2024/09/25 21:05:45 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.19

ARG EMAIL
ARG CERT_DIR

LABEL maintainer=${EMAIL}

EXPOSE 80

RUN apk add --no-cache nginx openssl shadow && \
	rm -f /var/cache/apk/*

RUN rm -rf /usr/share/nginx/html/*
COPY ./app /usr/share/nginx/html
COPY ./static-site.conf /etc/nginx/http.d/default.conf

RUN usermod -u 1000 nginx && groupmod -g 1000 nginx && \
	chown -R nginx:nginx /run/nginx /etc/nginx /var/lib/nginx /var/log/nginx /usr/share/nginx/html

USER nginx

CMD ["nginx", "-g", "daemon off;"]