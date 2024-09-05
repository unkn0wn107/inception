# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/05 17:31:21 by agaley            #+#    #+#              #
#    Updated: 2024/09/05 19:15:20 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.19

RUN apk add --no-cache redis

COPY redis.conf /etc/redis.conf

EXPOSE 6379

COPY --chmod=755 run.sh /usr/local/bin/run.sh

CMD [ "/usr/local/bin/run.sh" ]