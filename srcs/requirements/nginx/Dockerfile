# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 11:53:02 by agaley            #+#    #+#              #
#    Updated: 2024/03/27 15:52:31 by agaley           ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

LABEL maintainer=${EMAIL}

EXPOSE 443

RUN apk add --no-cache nginx openssl
RUN rm -f /var/cache/apk/*

ARG CERT_DIR
ARG DOMAIN_NAME
RUN mkdir -p ${CERT_DIR} && chmod 755 ${CERT_DIR}
COPY tools/gen-cert.sh /usr/local/bin/gen-cert.sh
RUN chmod +x /usr/local/bin/gen-cert.sh

COPY conf/wordpress.conf /etc/nginx/wordpress.conf

CMD ["/usr/local/bin/gen-cert.sh"]


CMD ["nginx", "-g", "daemon off;"]
