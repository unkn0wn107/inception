# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/25 18:14:48 by agaley            #+#    #+#              #
#    Updated: 2024/09/25 20:32:47 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.19

LABEL maintainer=${EMAIL}

RUN apk add --no-cache php82 php82-session php82-mysqli php82-pdo_mysql

RUN wget "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php" -O /srv/index.php

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/srv"]