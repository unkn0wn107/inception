# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/23 00:53:05 by agaley            #+#    #+#              #
#    Updated: 2024/09/18 23:25:21 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

include srcs/.env

VM_DISK=./vm.qcow2
VM_DISK_CONFIG=./user-data
VM_DISK_SEED=./seed.iso
VM_DISK_URL=https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2

MEMORY=4096
VCPU=8
SHARE_FOLDER=srcs
MOUNT_POINT=/home/$(LOGIN)/srcs

SSH_PORT=2222
HTTP_PORT=8080
HTTPS_PORT=8443

FTP_COMMAND_PORT=2121
FTP_DATA_PORT=2020
FTP_PASSIVE_PORT_MIN=30000
FTP_PASSIVE_PORT_MAX=30009

SSH=ssh -p $(SSH_PORT) $(LOGIN)@localhost
SUDO=$(SSH) sudo

COMPOSE=$(SSH) -t "cd /home/$(LOGIN)/srcs && docker compose"
SETUP_VM_SCRIPT=./srcs/setup_vm.sh

all:	vm-start vm-console vm-setup vm-mount build vm-perm up logs

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info:
	$(SSH) -t "echo '${BLUE}\n--- Running containers ---${NC}'; cd srcs && sudo docker ps; echo '${BLUE}\n--- Docker images ---${NC}'; sudo docker images; echo '${BLUE}\n--- Docker volumes ---${NC}'; sudo docker volume ls; echo '${BLUE}\n--- Docker networks ---${NC}'; sudo docker network ls; echo '\n'"

logs:
	$(COMPOSE) logs -f | sed -e 's/\(Error.*\)/${RED}\1${NC}/g' -e 's/\(Warning.*\)/${YELLOW}\1${NC}/g' -e 's/\(Info.*\)/${GREEN}\1${NC}/g'

watch:
	$(COMPOSE) watch

down:
	$(COMPOSE) down

clean:
	-$(COMPOSE) down --rmi all

fclean:	clean
	-$(SUDO) 'rm -rf /home/$(LOGIN)/data/wordpress && rm -rf /home/$(LOGIN)/data/mariadtob && rm -rf /home/$(LOGIN)/data/certs && docker system prune --all --volumes -f && docker volume rm certs-data db-data wp-data'
	@rm -f $(VM_DISK) $(VM_DISK_SEED) $(VM_DISK_CONFIG)

re:		kill fclean all

ssh:
	@echo "Attempting to connect to VM..."
	@for i in $$(seq 1 30); do \
		if nc -z localhost $(SSH_PORT); then \
			echo "Port $(SSH_PORT) is open. Attempting SSH..."; \
			$(SSH) -t "bash --login"; \
			exit 0; \
		fi; \
		echo "Waiting for SSH port to open... ($$i/30)"; \
		sleep 2; \
	done; \
	echo "Failed to connect after 60 seconds. Please check VM status."; \
	exit 1

kill:
	-pkill -f qemu-system-x86_64
	-pgrep -f qemu-system-x86_64 | xargs -r kill -9

check:
	cloud-init schema --config-file $(VM_DISK_CONFIG)

vm-perm:
	$(SUDO) 'chown -R $(LOGIN):$(LOGIN) /home/$(LOGIN)/data/'

vm-start:
	@if [ ! -f debian-12-generic-amd64.qcow2 ]; then \
		wget -O debian-12-generic-amd64.qcow2 $(VM_DISK_URL); \
	fi
	@if [ ! -f $(VM_DISK) ]; then \
		cp debian-12-generic-amd64.qcow2 $(VM_DISK); \
		qemu-img resize $(VM_DISK) +5G; \
	fi
	@if [ ! -f $(VM_DISK_SEED) ]; then \
		cp debian-12-generic-amd64.qcow2 $(VM_DISK); \
		sed -e 's/{{LOGIN}}/$(LOGIN)/g' \
			-e "s|{{SSH_PUBLIC_KEY}}|$(shell cat ~/.ssh/id_rsa.pub | sed 's/[\/&]/\\&/g')|g" \
			srcs/cloud-init.yml > $(VM_DISK_CONFIG); \
		cat $(VM_DISK_CONFIG); \
		echo "#cloud-config" > meta-data; \	
		xorriso -as mkisofs -o $(VM_DISK_SEED) -volid cidata -joliet -rock $(VM_DISK_CONFIG) meta-data; \
	fi
	@qemu-system-x86_64 \
		-m $(MEMORY) \
		-smp $(VCPU) \
		-drive file=$(VM_DISK),format=qcow2 \
		-drive file=$(VM_DISK_SEED),format=raw \
		-netdev user,id=mynetbase,hostfwd=tcp::$(SSH_PORT)-:22,hostfwd=tcp::${HTTP_PORT}-:80,hostfwd=tcp::${HTTPS_PORT}-:443 \
		-device virtio-net-pci,netdev=mynetbase \
		-netdev user,id=mynetftp,hostfwd=tcp::$(FTP_COMMAND_PORT)-:21,hostfwd=tcp::$(FTP_DATA_PORT)-:20 \
		-device virtio-net-pci,netdev=mynetftp \
		$(foreach port,$(shell seq $(FTP_PASSIVE_PORT_MIN) $(FTP_PASSIVE_PORT_MAX)),\
			-netdev user,id=mynet$(port),hostfwd=tcp::$(port)-:$(port) \
			-device virtio-net-pci,netdev=mynet$(port) \
		) \
		-fsdev local,security_model=passthrough,id=fsdev0,path=$(SHARE_FOLDER) \
		-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=share \
		-no-reboot \
		-serial mon:stdio \
		-nographic \
		-monitor unix:qemu-monitor-socket,server,nowait
	@echo "${GREEN}VM started in background. Use 'make vm-console' to access the console.${NC}"

vm-console:
	@echo "Connecting to QEMU monitor. Use 'quit' to exit, or 'system_powerdown' to shutdown the VM."
	@echo "For more commands, type 'help' in the monitor."
	@echo "To switch between console and monitor, use Ctrl-a c"
	-@nc -U qemu-monitor-socket

vm-setup:
	@while ! ssh -o ConnectTimeout=4 -p $(SSH_PORT) $(LOGIN)@localhost echo "${GREEN}VM is up !${NC}" 2>/dev/null; do \
		echo "${YELLOW}VM Starting ...${NC}"; \
		sleep 1; \
	done
	$(SSH) 'if ! id "$(LOGIN)" &>/dev/null || ! docker -v &>/dev/null; then \
		sudo bash -s; \
	fi' < $(SETUP_VM_SCRIPT)
	$(SSH) 'cd /home/$(LOGIN) && \
		mkdir -p ${CERTS_DATA} && \
		mkdir -p ${DB_DATA} && \
		mkdir -p ${WP_DATA} && \
		mkdir -p ${REDIS_DATA}'
	$(SUDO) 'chown -R $(LOGIN):$(LOGIN) /home/$(LOGIN)/data'

vm-mount:
	$(SUDO) 'mountpoint -q $(MOUNT_POINT) || mount -t 9p -o trans=virtio,version=9p2000.L share $(MOUNT_POINT)'

vm-ssh-copy:
	@if [ -f ~/.ssh/id_rsa.pub ]; then \
		if ! ssh -o PasswordAuthentication=no -o BatchMode=yes -p $(SSH_PORT) -i ~/.ssh/id_rsa root@localhost echo "${GREEN}root SSH key already added${NC}" 2>/dev/null; then \
			ssh-copy-id -i ~/.ssh/id_rsa -p $(SSH_PORT) root@localhost; \
		fi; \
		if ! ssh -o PasswordAuthentication=no -o BatchMode=yes -p $(SSH_PORT) -i ~/.ssh/id_rsa $(LOGIN)@localhost echo "${GREEN}user SSH key already added${NC}" 2>/dev/null; then \
			ssh-copy-id -i ~/.ssh/id_rsa -p $(SSH_PORT) $(LOGIN)@localhost; \
		fi; \
	fi

vm-stop:
	$(SUDO) 'systemctl poweroff'

.PHONY: all build up down clean fclean re ssh vm-ready vm-start vm-stop vm-setup vm-mount vm-ssh-copy vm-console
