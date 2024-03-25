# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/25 14:32:11 by agaley            #+#    #+#              #
#    Updated: 2024/03/25 14:47:29 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

LABEL maintainer=${EMAIL}

EXPOSE 6081

RUN ["apk", "add", "--no-cache", "varnish=6"]
RUN rm -f /var/cache/apk/*

COPY conf/wordpress.vcl /etc/varnish/wordpress.vcl

CMD ["varnishd", "-F", "-a", ":6081", "-f", "/etc/varnish/wordpress.vcl"]
