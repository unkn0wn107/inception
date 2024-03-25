# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/25 03:20:24 by agaley            #+#    #+#              #
#    Updated: 2024/03/25 14:33:19 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

LABEL maintainer=${EMAIL}

EXPOSE 6379

RUN ["apk", "add", "--no-cache", "redis"]
RUN rm -f /var/cache/apk/*

COPY conf/redis.conf /etc/redis.conf
RUN ["mkdir", "/data"]
RUN ["chown", "redis:redis", "/data"]
VOLUME /data
WORKDIR /data

CMD ["redis-server", "/etc/redis.conf"] 
