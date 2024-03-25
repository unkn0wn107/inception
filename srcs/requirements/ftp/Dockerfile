# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/25 11:02:00 by agaley            #+#    #+#              #
#    Updated: 2024/03/25 15:02:54 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

LABEL maintainer=${EMAIL}

EXPOSE 21 30000-30100

RUN ["apk", "add", "--no-cache", "vsftpd", "bash", "openssl"]
RUN rm -f /var/cache/apk/*

RUN adduser -D ftpuser && echo "ftpuser:ftppassword" | chpasswd

COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

RUN mkdir -p /home/ftpuser/ftp && \
    chown nobody:nogroup /home/ftpuser/ftp && \
    chmod a-w /home/ftpuser/ftp && \
    mkdir -p /home/ftpuser/ftp/files && \
    chown ftpuser:ftpuser /home/ftpuser/ftp/files

VOLUME ["/home/ftpuser/ftp/files"]

ENTRYPOINT ["vsftpd", "/etc/vsftpd/vsftpd.conf", "-opasv_min_port=30000", "-opasv_max_port=30100", "-oforeground=YES"]
