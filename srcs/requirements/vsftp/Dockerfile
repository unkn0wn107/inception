# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/05 19:48:55 by agaley            #+#    #+#              #
#    Updated: 2024/09/05 20:03:33 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.19

RUN apk add --no-cache vsftpd

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

EXPOSE 20 21 30000-30009

COPY --chmod=755 run.sh /usr/local/bin/run.sh

CMD [ "/usr/local/bin/run.sh" ]