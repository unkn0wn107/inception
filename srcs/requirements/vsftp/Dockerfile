# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/05 19:48:55 by agaley            #+#    #+#              #
#    Updated: 2024/09/25 20:07:36 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.19

LABEL maintainer=${EMAIL}

RUN apk add --no-cache vsftpd

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

COPY --chmod=755 run.sh /usr/local/bin/run.sh

CMD [ "/usr/local/bin/run.sh" ]