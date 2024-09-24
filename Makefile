# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/23 00:53:05 by agaley            #+#    #+#              #
#    Updated: 2024/09/24 11:54:21 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

include srcs/.env

SSH=ssh -p $(SSH_PORT) $(LOGIN)@localhost
SUDO=$(SSH) sudo

COMPOSE=$(SSH) -t "cd /home/$(LOGIN)/srcs && docker compose"

all:	vm-start build vm-perm up logs

build:
	$(call wait_for_ssh)
	$(COMPOSE) build

up:
	$(call wait_for_ssh)
	$(COMPOSE) up -d

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
	@rm -f $(VM_DISK) $(VM_DISK_SEED) $(VM_STORE_DISK) $(VM_DISK_CONFIG)

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

vm-start: vm-prepare vm-run

vm-prepare:
	@if [ ! -f debian-12-generic-amd64.qcow2 ]; then \
		wget -O debian-12-generic-amd64.qcow2 $(VM_DISK_URL); \
	fi
	@if [ ! -f $(VM_DISK) ]; then \
		cp debian-12-generic-amd64.qcow2 $(VM_DISK); \
		qemu-img resize $(VM_DISK) +5G; \
	fi
	@if [ ! -f $(VM_STORE_DISK) ]; then \
		qemu-img create -f qcow2 $(VM_STORE_DISK) 5G; \
	fi
	@if [ ! -f $(VM_DISK_SEED) ]; then \
		sed -e 's/{{LOGIN}}/$(LOGIN)/g' \
			-e "s|{{SSH_PUBLIC_KEY}}|$(shell cat ~/.ssh/id_rsa.pub | sed 's/[\/&]/\\&/g')|g" \
			srcs/cloud-init.yml > $(VM_DISK_CONFIG); \
		echo "#cloud-config" > meta-data; \
		xorriso -as mkisofs -o $(VM_DISK_SEED) -volid cidata -joliet -rock $(VM_DISK_CONFIG) meta-data; \
	fi

vm-run:
	@qemu-system-x86_64 \
		-m $(MEMORY) \
		-smp $(VCPU) \
		-drive file=$(VM_DISK),format=qcow2,if=virtio,index=1 \
		-drive file=$(VM_DISK_SEED),format=raw,if=virtio,index=0 \
		-drive file=$(VM_STORE_DISK),format=qcow2,if=virtio,index=2 \
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
		-monitor unix:qemu-monitor-socket,server,nowait &
	@echo "${GREEN}VM started in background. Waiting for boot to complete...${NC}"
	@$(MAKE) vm-console

vm-console:
	@echo "Connecting to QEMU monitor. Use 'quit' to exit, or 'system_powerdown' to shutdown the VM."
	@echo "For more commands, type 'help' in the monitor."
	@echo "To switch between console and monitor, use Ctrl-a c"
	@echo "Press Ctrl-C to exit when boot is complete and continue with the build process."
	-@nc -U qemu-monitor-socket || true

vm-stop:
	$(SUDO) 'systemctl poweroff'

.PHONY: all build up down clean fclean re ssh vm-ready vm-start vm-stop vm-setup vm-mount vm-ssh-copy vm-console vm-prepare vm-run

define wait_for_ssh
	@for i in $$(seq 1 30); do \
		if $(SSH) -q exit; then \
			echo "VM is ready."; \
			break; \
		fi; \
		echo "Waiting for SSH connection... ($$i/30)"; \
		sleep 5; \
	done
	@if ! $(SSH) -q exit; then \
		echo "${RED}Failed to connect to SSH after multiple attempts.${NC}"; \
		exit 1; \
	fi
endef
