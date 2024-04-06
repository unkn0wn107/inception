# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 11:53:02 by agaley            #+#    #+#              #
#    Updated: 2024/04/06 05:54:10 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

LABEL maintainer=${EMAIL}

EXPOSE 443

RUN apk add --no-cache nginx openssl shadow
RUN rm -f /var/cache/apk/*

RUN usermod -u 1000 nginx && groupmod -g 1000 nginx
RUN chown -R nginx:nginx /run/nginx /etc/nginx /var/lib/nginx /var/log/nginx

ARG CERT_DIR
RUN mkdir -p ${CERT_DIR} && chmod 755 ${CERT_DIR}
COPY --chmod=755 tools/run.sh /usr/local/bin/run.sh

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

USER nginx

RUN rm /etc/nginx/http.d/default.conf
COPY conf/wordpress.conf /etc/nginx/http.d/wordpress.conf

CMD ["/usr/local/bin/run.sh"]
