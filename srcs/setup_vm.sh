#!/bin/sh
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    setup_vm.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/23 01:07:12 by agaley            #+#    #+#              #
#    Updated: 2024/03/24 03:41:38 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

useradd -m $LOGIN
echo "$LOGIN:$PASS" | chpasswd
echo "$LOGIN ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$LOGIN

apt-get clean
rm -rf /var/lib/apt/lists/*
apt-get update
apt-get install -y ca-certificates curl gnupg apt-transport-https
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

groupadd docker
usermod -aG docker $LOGIN
