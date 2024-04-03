# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 15:24:19 by agaley            #+#    #+#              #
#    Updated: 2024/04/03 20:49:02 by agaley           ###   ########lyon.fr    #
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

COPY ["conf/my.cnf", "/etc/mysql/my.cnf"]
COPY --chmod=755 ["tools/run.sh", "/usr/local/bin/run.sh"]

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/usr/local/bin/run.sh"]
