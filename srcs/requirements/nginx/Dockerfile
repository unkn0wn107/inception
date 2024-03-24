# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 11:53:02 by agaley            #+#    #+#              #
#    Updated: 2024/03/24 15:19:35 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

LABEL maintainer=${EMAIL}

RUN apk add --no-cache nginx openssl

EXPOSE 443

ARG CERT_DIR
RUN mkdir -p ${CERT_DIR} && chmod 700 ${CERT_DIR}
COPY tools/gen-cert.sh /usr/local/bin/gen-cert.sh
RUN chmod +x /usr/local/bin/gen-cert.sh && /usr/local/bin/gen-cert.sh

COPY conf/wordpress.conf /etc/nginx/wordpress.conf

CMD ["nginx", "-g", "daemon off;"]
