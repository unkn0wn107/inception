# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: agaley <agaley@student.42lyon.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/23 00:53:05 by agaley            #+#    #+#              #
#    Updated: 2024/09/26 02:27:28 by agaley           ###   ########lyon.fr    #
#                                                                              #
# **************************************************************************** #

-include srcs/.env

SSH=ssh -p $(SSH_PORT) $(LOGIN)@localhost
SUDO=$(SSH) sudo

COMPOSE=$(SSH) -t "cd /home/$(LOGIN)/srcs && docker compose"

SSH_FWD=hostfwd=tcp::$(SSH_PORT)-:22
HTTP_FWD=hostfwd=tcp::${HTTP_PORT}-:80,hostfwd=tcp::${HTTPS_PORT}-:443
STATIC_FWD=hostfwd=tcp::${STATIC_PORT}-:${STATIC_PORT}
ADMINER_FWD=hostfwd=tcp::${ADMINER_PORT}-:${ADMINER_PORT}
MAILHOG_FWD=hostfwd=tcp::${MAILHOG_PORT}-:${MAILHOG_PORT}
FTP_FWD=hostfwd=tcp::$(FTP_COMMAND_PORT)-:$(FTP_COMMAND_PORT),hostfwd=tcp::$(FTP_DATA_PORT)-:$(FTP_DATA_PORT)
FTP_PASSIVE_PORTS=$(shell seq $(FTP_PASSIVE_PORT_MIN) $(FTP_PASSIVE_PORT_MAX))
FTP_PASSIVE_FWD=$(foreach port,$(FTP_PASSIVE_PORTS),hostfwd=tcp::$(port)-:$(port))

FWD_LIST=$(shell echo "$(SSH_FWD),$(HTTP_FWD),$(STATIC_FWD),$(ADMINER_FWD),$(MAILHOG_FWD),$(FTP_FWD),$(FTP_PASSIVE_FWD)" | \
	sed 's/,\s*$$//' | \
	tr ' ' ',')

all:	init-env vm-check wait-cloud-init up logs

up:
	$(COMPOSE) up --build -d

info:
	$(SSH) -t "echo '${BLUE}\n--- Running containers ---${NC}'; cd srcs && sudo docker ps; echo '${BLUE}\n--- Docker images ---${NC}'; sudo docker images; echo '${BLUE}\n--- Docker volumes ---${NC}'; sudo docker volume ls; echo '${BLUE}\n--- Docker networks ---${NC}'; sudo docker network ls; echo '\n'"

logs:
	$(COMPOSE) logs -f | sed -e 's/\(Error.*\)/\x1b[0;31m\1\x1b[0m/g' -e 's/\(Warning.*\)/\x1b[0;33m\1\x1b[0m/g' -e 's/\(Info.*\)/\x1b[0;32m\1\x1b[0m/g'

watch:
	$(COMPOSE) watch

down:
	$(COMPOSE) down

stop: down
	$(SUDO) 'systemctl poweroff'

clean:
	-$(COMPOSE) down --rmi all

fclean:	clean
	-$(SUDO) 'rm -rf /home/$(LOGIN)/data/wordpress && rm -rf /home/$(LOGIN)/data/mariadtob && rm -rf /home/$(LOGIN)/data/certs && docker system prune --all --volumes -f && docker volume rm certs-data db-data wp-data'
	@rm -f $(VM_DISK) $(VM_DISK_SEED) $(VM_DISK_CONFIG)

re:		kill fclean all

status:
	$(SSH) cloud-init status

wait-cloud-init:
	@echo "Waiting for cloud-init to complete..."
	@for i in $$(seq 1 100); do \
		status=yes; \
		status=$$($(SSH) cloud-init status | grep status | awk '{print $$2}'); \
		if [ "$$status" = "done" ]; then \
			echo "Cloud-init completed successfully."; \
			exit 0; \
		elif [ "$$status" = "error" ]; then \
			echo "Cloud-init failed. Check logs for details."; \
			exit 1; \
		fi; \
		echo "Cloud-init status: $$status (attempt $$i/100)"; \
		sleep 5; \
	done; \
	echo "Timeout waiting for cloud-init to complete. Check VM status."; \
	exit 1

console:
	@echo "Connecting to QEMU monitor. Use 'quit' to exit, or 'system_powerdown' to shutdown the VM."
	@echo "For more commands, type 'help' in the monitor."
	@echo "To switch between console and monitor, use Ctrl-a c"
	@echo "Press Ctrl-C to exit when boot is complete and continue with the build process."
	-@nc -U qemu-monitor-socket || true

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
	-rm qemu-monitor-socket

vm-check-config:
	cloud-init schema --config-file $(VM_DISK_CONFIG)

vm-check:
	@if [ -e qemu-monitor-socket ]; then \
		echo "VM is already running. Using it."; \
	else \
		echo "VM is not running. Starting VM..."; \
		$(MAKE) vm-start; \
	fi

vm-start: vm-prepare vm-run

vm-prepare:
	@if [ ! -f debian-12-generic-amd64.qcow2 ]; then \
		wget -O debian-12-generic-amd64.qcow2 $(VM_DISK_URL); \
	fi
	@if [ ! -f $(VM_DISK) ]; then \
		cp debian-12-generic-amd64.qcow2 $(VM_DISK); \
		qemu-img resize $(VM_DISK) +5G; \
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
		-netdev user,id=mynet0,$(FWD_LIST) \
		-device virtio-net-pci,netdev=mynet0 \
		-fsdev local,security_model=passthrough,id=fsdev0,path=$(SHARE_FOLDER) \
		-device virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=share \
		-no-reboot \
		-serial mon:stdio \
		-nographic \
		-monitor unix:qemu-monitor-socket,server,nowait & \
	echo "${GREEN}VM started in background. Waiting for boot to complete...${NC}"; \
	$(MAKE) vm-console;

init-env:
	@if ! command -v openssl >/dev/null 2>&1; then \
		echo "OpenSSL is required to create credentials."; \
		echo "Please install openssl or create .env file manually."; \
		exit 1; \
	fi
	@if [ ! -f srcs/.env ]; then \
		echo "Creating .env ..."; \
		cp srcs/.env.example srcs/.env; \
		sed -i 's|^LOGIN=.*|LOGIN=$(shell whoami)|' srcs/.env; \
		sed -i 's|^VM_LOGIN_PASS=.*|VM_LOGIN_PASS=$(shell openssl rand -base64 12)|' srcs/.env; \
		sed -i 's|^DB_ROOT_PASS=.*|DB_ROOT_PASS=$(shell openssl rand -base64 12)|' srcs/.env; \
		sed -i 's|^DB_PASS=.*|DB_PASS=$(shell openssl rand -base64 12)|' srcs/.env; \
		sed -i 's|^WP_ADMIN_PASS=.*|WP_ADMIN_PASS=$(shell openssl rand -base64 12)|' srcs/.env; \
		sed -i 's|^WP_USER_PASS=.*|WP_USER_PASS=$(shell openssl rand -base64 12)|' srcs/.env; \
		sed -i 's|^REDIS_PASS=.*|REDIS_PASS=$(shell openssl rand -base64 12)|' srcs/.env; \
		sed -i 's|^FTP_PASS=.*|FTP_PASS=$(shell openssl rand -base64 12)|' srcs/.env; \
		echo "Created .env file with secure passwords."; \
	else \
		echo ".env file already exists. Using it."; \
	fi

.PHONY: all up info logs watch down stop clean fclean re status wait-cloud-init console ssh kill vm-check-config vm-check vm-start vm-prepare vm-run init-env