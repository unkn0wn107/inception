# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/09/25 18:14:48 by agaley            #+#    #+#              #
#    Updated: 2024/09/25 23:18:50 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

FROM alpine:3.19

LABEL maintainer=${EMAIL}

RUN apk add --no-cache go git

RUN mkdir -p /go/src/github.com/mailhog && \
	cd /go/src/github.com/mailhog && \
	git clone https://github.com/mailhog/MailHog.git && \
	cd MailHog && \
	go mod init github.com/mailhog/MailHog && \
	go mod tidy && \
	go build -mod=mod -o MailHog

EXPOSE 1025 8025

WORKDIR /go/src/github.com/mailhog/MailHog

CMD ["./MailHog"]