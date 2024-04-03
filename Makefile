# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/23 00:53:05 by agaley            #+#    #+#              #
#    Updated: 2024/04/03 18:04:33 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

include srcs/.env

VM_DISK=./vm.qcow2
MEMORY=8192
VCPU=8
SHARE_FOLDER=srcs
MOUNT_POINT=/home/$(LOGIN)/srcs

SSH_PORT=2222
HTTP_PORT=8080
HTTPS_PORT=4343
SSH_ROOT=@ssh -p $(SSH_PORT) root@localhost
SSH=@ssh -i ~/.ssh/id_rsa -p $(SSH_PORT) $(LOGIN)@localhost

COMPOSE=$(SSH) -t "cd srcs && docker compose"
SETUP_VM_SCRIPT=./srcs/setup_vm.sh

all:	data-dir build up

build:	vm-ready
	$(COMPOSE) build

up: 	vm-ready
	$(COMPOSE) up -d

info:
	$(SSH) -t "echo '\n--- Running containers ---'; cd srcs && docker ps; echo '\n--- Docker images ---'; docker images; echo '\n--- Docker volumes ---'; docker volume ls; echo '\n--- Docker networks ---'; docker network ls; echo '\n'"

logs: 	vm-ready
	$(COMPOSE) logs -f

down:	vm-ready
	$(COMPOSE) down

clean:	vm-ready
	$(COMPOSE) down --rmi all

fclean:	clean
	$(SSH_ROOT) 'docker container prune -f && docker volume prune -f --filter all=1 && docker network prune -f && rm -rf /home/$(LOGIN)/data/*'

re:		down clean all

ssh:	vm-ready vm-ssh-copy
	$(SSH) -t "bash --login"

vm-ready: vm-setup vm-mount

vm-start:
	@qemu-img check $(VM_DISK) > /dev/null 2>&1; \
	if [ $$? -eq 1 ]; then \
		echo "VM already running ..."; \
	else \
		qemu-system-x86_64 \
		-m $(MEMORY) \
		-smp $(VCPU) \
		-drive file=$(VM_DISK),format=qcow2 \
		-net nic \
		-net user,hostfwd=tcp::$(SSH_PORT)-:22,hostfwd=tcp::${HTTP_PORT}-:80,hostfwd=tcp::${HTTPS_PORT}-:43 \
		-fsdev local,security_model=passthrough,id=fsdev0,path=$(SHARE_FOLDER) \
		-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=share \
		& \
	fi

vm-stop:
	$(SSH_ROOT) 'systemctl poweroff'

vm-setup: vm-start
	@while ! ssh -o ConnectTimeout=2 -p $(SSH_PORT) root@localhost echo "VM is up !" 2>/dev/null; do \
		echo "VM Starting ..."; \
		sleep 4; \
	done
	$(SSH_ROOT) 'if ! id "$(LOGIN)" &>/dev/null || ! docker -v &>/dev/null; then export LOGIN="$(LOGIN)" && export PASS="$(VM_LOGIN_PASS)" && bash -s; fi' < $(SETUP_VM_SCRIPT)

vm-mount:
	$(SSH_ROOT) 'mountpoint -q $(MOUNT_POINT) || mount -t 9p -o trans=virtio,version=9p2000.L share $(MOUNT_POINT)'

vm-ssh-copy:
	@if [ -f ~/.ssh/id_rsa.pub ] && ! ssh -o BatchMode=yes -o ConnectTimeout=5 -p $(SSH_PORT) $(LOGIN)@localhost 'exit' 2>&1; then \
		ssh-copy-id -i ~/.ssh/id_rsa -p $(SSH_PORT) $(LOGIN)@localhost; \
	fi

data-dir:
	@mkdir -p data/certs
	@mkdir -p data/mariadb
	@mkdir -p data/wordpress
	@mkdir -p data/static-website

.PHONY: all build up down clean fclean re ssh vm-ready vm-start vm-stop vm-setup vm-mount vm-ssh-copy data-dir
