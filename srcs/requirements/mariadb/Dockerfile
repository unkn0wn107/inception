# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 15:24:19 by agaley            #+#    #+#              #
#    Updated: 2024/03/25 02:58:27 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

LABEL maintainer=${EMAIL}

EXPOSE 3306

RUN apk add --no-cache mariadb mariadb-client mariadb-server-utils
RUN rm -f /var/cache/apk/*

RUN ["mkdir", "-p", "/run/mysqld"]
RUN ["chown", "-R", "mysql:mysql", "/run/mysqld"]
RUN ["chown", "-R", "mysql:mysql", "/var/lib/mysql"]
RUN ["chmod", "755", "/var/lib/mysql"]
RUN ["mkdir", "-p", "/var/log/mysql"]
RUN ["chown", "-R", "mysql:mysql", "/var/log/mysql"]
RUN ["mysql_install_db", "--user=mysql", "--ldata=/var/lib/mysql"]

COPY conf/my.cnf /etc/mysql/my.cnf
COPY tools/setup-db.sh /usr/local/bin/setup-db.sh
RUN ["chmod", "+x", "/usr/local/bin/setup-db.sh"]

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/usr/local/bin/setup-db.sh"]
