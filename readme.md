# Inception Local Docker Infrastructure

## The PASIV device !

## Overview

The **The PASIV device (Inception)** project sets up a Docker-based environment within a QEMU/KVM virtual machine (VM). This infrastructure includes multiple services for a wordpress application, such as NGINX with TLS, WordPress with PHP-FPM, MariaDB, Redis, FTP server, a static website, Adminer for database management, and Varnish for caching. The entire setup is automated using cloud-init for OS layer and docker compose for application layer.

## Features

- **Virtual Machine Setup**: QEMU/KVM to run a Debian-based VM with auto cloud-init configuration.
- **Dockerized Services**:
  - **NGINX**: Reverse proxy with TLSv1.2/1.3 for secure connections.
  - **WordPress + PHP-FPM**: WordPress application based on [Roots Bedrock](https://roots.io/bedrock/).
  - **MariaDB**: WordPress database.
  - **Redis**: Object caching for performance.
  - **FTP Server**: File transfers to WordPress.
  - **Static Website**: Simple js static site.
  - **Adminer**: Web-based database management.
  - **Varnish**: Implements caching to improve content delivery speed.
- **Automated Management**: Controlled via Makefile commands for easy setup, teardown, and maintenance.
- **Secure Configuration**: Environment variables and `.env` files manage sensitive data without hardcoding credentials.
- **Persistent Storage**: Utilizes Docker volumes to ensure data persistence across container restarts.


## Prerequisites

- **Host Machine**:
  - Linux-based operating system.
  - QEMU/KVM installed and configured.
  - Docker and Docker Compose installed.
  - Make utility installed.
  - SSH access with a public key.
  
- **Virtual Machine**:
  - Debian 12 (or compatible) as the base image.
  - Sufficient resources allocated (e.g., 4GB RAM, 4 CPU cores).

## Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/inception-docker-infrastructure.git
   cd inception-docker-infrastructure
   ```

2. **Configure Environment Variables**:
   - Navigate to the `srcs` directory.
   - Create a `.env` file based on the provided template:
     ```bash
     cp .env.example .env
     ```
   - Populate the `.env` file with your configurations, such as domain name, passwords, and ports.

3. **Prepare the Virtual Machine**:
   - Ensure that the VM image (`debian-12-generic-amd64.qcow2`) is present in the root directory. If not, the Makefile will attempt to download and prepare it.

4. **Run the Makefile**:
   - From the root directory, execute:
     ```bash
     make all
     ```
   - This command will:
     - Start the VM.
     - Set up SSH access.
     - Mount shared directories.
     - Build and launch all Docker containers.
     - Tail the logs for real-time monitoring.

5. **Access the Services**:
   - **WordPress**: `https://yourdomain.com:443`
   - **Static Site**: `http://yourdomain.com:80`
   - **Adminer**: `http://yourdomain.com:8080`
   - **FTP Server**: Connect using your FTP client to the configured ports.

## Commands

- **Create VM and start All Services**:
  ```bash
  make
  ```
When cloud init has reached the target, press enter and approve the new server.
Services will then build and start.
  
- **Bring up services (after changes)**:
  ```bash
  make up
  ```
  
- **View service logs**:
  ```bash
  make logs
  ```
  
- **Stop and remove services**:
  ```bash
  make down
  ```
  
- **Clean resources**:
  ```bash
  make clean
  ```
  
- **Cleaning Up ! - Delete VM**:
  - To remove VM and all containers, images, volumes, and networks:
    ```bash
    make fclean
    ```
  
- **fclean, recreates VM and services**:
  ```bash
  make re
  ```
  
- **Connect to VM via SSH**:
  ```bash
  make ssh
  ```
  
- **Check VM Status**:
  ```bash
  make vm-check
  ```

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

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- [Inception Project](https://projects.intra.42.fr/projects/inception) for 42 School.
