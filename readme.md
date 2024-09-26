# Inception Local Docker Infrastructure

## TLDR

`make`

42 stud : Use responsibly, this is not made for you to instant pass inception project.
The goal is to demonstrate the power of server-vm (vs virtual*** graphical f**** VMs) coupled with a bashy-style infrastructure-as-code.


## The PASIV device !

The PASIV (Portable Automated Somnacin IntraVenous) device is a compact machine that allows multiple people to share a dream state. Much like how the PASIV device creates a layered dream world, this project sets up a multi-layered, interconnected infrastructure using Docker containers within a virtual machine.

Just as the PASIV device requires careful configuration and synchronization to create a stable shared dream, our project uses Docker Compose to orchestrate multiple services, ensuring they work together seamlessly. The virtual machine acts as the "first level" of the dream, with each Docker container representing a deeper layer of functionality.

What you get from the PASIV device ? (Except a single `make` press !) 

1. Layered Architecture: Multiple interconnected agents (containers) within a controlled environment (VM).
2. Precise Timing: Automated setup and synchronization of services.
3. Shared Resources: Containers communicate and share data, much like dreamers sharing a dream space.
4. Stability: Carefully configured to maintain a stable environment.
5. Portability: The entire setup can be recreated on different host systems.
6. Reality Check: Cloud-init status verification ensures the environment is properly initialized, much like a totem confirms the dreamer's reality.

By pressing `make`, you initiate a process akin to activating the PASIV device. The system automates the setup of your multi-layered infrastructure, allowing you to dive deep into a world of interconnected agents while going deeper into your dream.

![Pasiv device](https://static1.srcdn.com/wordpress/wp-content/uploads/2023/03/how-inception-s-dream-machine-works.jpg?q=50&fit=crop&w=1140&h=&dpr=1.5)

## Overview

The **The PASIV device (Inception)** project sets up a Docker-based development environment within a QEMU/KVM virtual machine (VM). This infrastructure includes multiple services for a wordpress application, such as NGINX with TLS, WordPress with PHP-FPM, MariaDB, Redis, FTP server, a static website, Adminer for database management, and Varnish for caching. The entire setup is automated using cloud-init for OS layer and docker compose for application layer.

It is the continuity of [Auto Born2BeRoot](https://github.com/unkn0wn107/Born2beRoot) using more modern technologies : cloud-init vs tiresome preseed and docker compose for service layer.


## Features

- **Virtual Machine Setup**: QEMU/KVM to run a Debian-based VM with auto cloud-init configuration.
- **Dockerized Services**:
  - **Alpine**: All services are built on scratch alpine:3.19.
  - **NGINX**: Reverse proxy with TLSv1.2/1.3.
  - **WordPress + PHP-FPM**: WordPress application based on [Roots Bedrock](https://roots.io/bedrock/).
  - **MariaDB**: WordPress database.
  - **Redis**: Object caching for performance, linked to Wordpress redis cache plugin.
  - **FTP Server**: File transfers to WordPress : `ftp localhost 2121`.
  - **Static Website**: Simple js ~~static~~ stupid site.
  - **Adminer**: Web-based database management.
  - **Mailhog**: Development environment mail all-catcher set-up with Wordpress.
- **Automated Management**: Controlled via Makefile commands for easy setup, teardown, and maintenance.
- **Secure Configuration**: Environment variables and `.env` files manage sensitive data without hardcoding credentials.
- **Persistent Storage**: Utilizes Docker volumes to ensure data persistence across container restarts.


## Prerequisites

- **Host Machine**:
  - Linux-based operating system.
  - QEMU/KVM installed and configured.
  - Make.
  - SSH access with a public key ~/.ssh/id_rsa.pub.
  - A local dns record /etc/hosts : 127.0.0.1   marvin.42.fr
	(there is a hack with fakedns for rootless machine)
  
- **Virtual Machine**:
  - Resources : adjust default MEMORY=8192 VCPU=16 in .env.example or .env.


## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/unkn0wn107/inception
   cd inception
   ```

2. **Adjust VM resources MEMORY VCPU in .env.example**

3. **Run the Makefile**:
   - From the root directory, execute:
     ```bash
     make
     ```
   - This command will (do everything) :
     - Create and populate .env file with credentials.
	 - Download latest debian 12 generic cloud image.
	 - Seed the image with cloud-init.
     - Set up SSH access.
     - Mount shared directories.
     - Build and launch all Docker containers.
     - Log for real-time monitoring.

4. **Access the Services**:
   - **WordPress**: `https://marvin.42lyon.fr:8443`
   - **Stupid Site**: `http://marvin.42lyon.fr:8090`
   - **Adminer**: `http://marvin.42lyon.fr:8081`
   - **Mail Hog**: `http://marvin.42lyon.fr:8025`
   - **FTP Server**: `ftp localhost 2121`


## Commands

- **Create VM and start All Services**: `make`
- **Bring up services (after modification)**: `make up`
- **View services logs**: `make logs`
- **Connect to VM via SSH**: `make ssh`
- **Enter VM Qemu Console**: `make console`
- **Stop services**: `make down`
- **Clean resources (except long-term data)**: `make clean`
- **Delete VM and all resources**: `make fclean`
- **Recreate VM and services**: `make re`

![Commands](https://resize-v3.pubpub.org/eyJidWNrZXQiOiJhc3NldHMucHVicHViLm9yZyIsImtleSI6ImY1ZDQxazd3LzExNTY5MjAxOTc1MTA1LmpwZyIsImVkaXRzIjp7InJlc2l6ZSI6eyJ3aWR0aCI6ODAwLCJmaXQiOiJpbnNpZGUiLCJ3aXRob3V0RW5sYXJnZW1lbnQiOnRydWV9fX0=)


## Docker Compose Configuration

The `docker-compose.yml` file orchestrates the deployment of all services with the following key configurations:

- **Networks**:
  - `frontend`: For services exposed to the external network (e.g., NGINX, Static Site, FTP).
  - `backend`: For internal communication between services (e.g., WordPress, MariaDB, Redis).

- **Volumes**:
  - Persistent storage for WordPress content, MariaDB data, Redis cache etc.

- **Service Definitions**:
  - Each service is built from its respective `Dockerfile` located in the `requirements` directory.
  - Environment variables are managed through the `.env` file, example in .env.example.


## Xorriso vs cloud-localds

I used xorriso to patch cloud-init config because cloud-localds was not available on school machines.
See commit eb3719e for cloud-localds approach.


## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- [Inception Project](https://projects.intra.42.fr/projects/inception) for 42 School.
