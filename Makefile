# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/23 00:53:05 by agaley            #+#    #+#              #
#    Updated: 2024/03/24 05:24:39 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

include .env

VM_DISK=./vm.qcow2
MEMORY=4096
VCPU=4
SSH_PORT=2222
SHARE_FOLDER=.
MOUNT_POINT=/home/$(LOGIN)/

SETUP_VM_SCRIPT=./srcs/setup_vm.sh

all:	build up

build:	vm-ready
	cd srcs && docker compose build

up: 	vm-ready
	cd srcs && docker compose up -d

down:	vm-ready
	cd srcs && docker compose down

clean:	vm-ready
	cd srcs && docker compose down --rmi all

re:		clean down all

ssh:	vm-ready vm-ssh-copy
	ssh -p $(SSH_PORT) $(LOGIN)@localhost -t "bash --login"

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
		-net user,hostfwd=tcp::$(SSH_PORT)-:22 \
		-fsdev local,security_model=passthrough,id=fsdev0,path=$(SHARE_FOLDER) \
		-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=share \
		& \
	fi

vm-stop:
	@ssh -p $(SSH_PORT) root@localhost 'systemctl poweroff'

vm-setup: vm-start
	@while ! ssh -o ConnectTimeout=2 -p $(SSH_PORT) root@localhost echo "VM is up !" 2>/dev/null; do \
		echo "VM Starting ..."; \
		sleep 4; \
	done
	@ssh -p $(SSH_PORT) root@localhost 'if ! id "$(LOGIN)" &>/dev/null || ! docker -v &>/dev/null; then export LOGIN="$(LOGIN)" && export PASS="$(VM_LOGIN_PASS)" && bash -s; fi' < $(SETUP_VM_SCRIPT)

vm-mount:
	@ssh -p $(SSH_PORT) root@localhost 'mountpoint -q $(MOUNT_POINT) || mount -t 9p -o trans=virtio,version=9p2000.L share $(MOUNT_POINT)'

vm-ssh-copy:
	@if [ -f ~/.ssh/id_rsa.pub ]; then \
		ssh-copy-id -i ~/.ssh/id_rsa.pub -p $(SSH_PORT) $(LOGIN)@localhost; \
	fi

.PHONY: all build up down clean fclean re ssh vm-ready vm-start vm-stop vm-setup vm-mount vm-ssh-copy

