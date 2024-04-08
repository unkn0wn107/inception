# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/24 15:24:19 by agaley            #+#    #+#              #
#    Updated: 2024/04/08 01:40:59 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.18

ARG EMAIL

LABEL maintainer=${EMAIL}

EXPOSE 3306

RUN apk add --no-cache shadow mariadb mariadb-client mariadb-server-utils
RUN rm -f /var/cache/apk/*

RUN usermod -u 1000 mysql && groupmod -g 1000 mysql

RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld && \
	chown -R mysql:mysql /var/lib/mysql && chmod 755 /var/lib/mysql
RUN ["mariadb-install-db", "--user=mysql", "--ldata=/var/lib/mysql"]

COPY ["conf/my.cnf", "/etc/mysql/my.cnf"]
COPY --chmod=755 ["tools/run.sh", "/usr/local/bin/run.sh"]

VOLUME ["/var/lib/mysql"]

HEALTHCHECK --interval=5s --timeout=60s --retries=10 CMD sh -c 'mysqladmin ping -h localhost || exit 1'

WORKDIR /var/lib/mysql

CMD ["/usr/local/bin/run.sh"]
