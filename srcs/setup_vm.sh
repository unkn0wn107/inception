#!/bin/sh

# For debian based .qcow2 image
export DEBIAN_FRONTEND=noninteractive

# useradd -m $LOGIN
# echo "$LOGIN:$PASS" | chpasswd
# echo "$LOGIN ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$LOGIN

# apt-get clean
# rm -rf /var/lib/apt/lists/*

# ls /dev/

# # Attempt to unmount /dev/sdb1 if it's mounted
# echo "Attempting to unmount /dev/sdb1..."
# umount /dev/sdb1 2>/dev/null || echo "No need to unmount /dev/sdb1"
# sleep 2

# # Check if any processes are using /dev/sdb
# echo "Checking for processes using /dev/sdb..."
# lsof | grep /dev/sdb || echo "No processes are using /dev/sdb"

# # Wipe the partition table
# echo "Wiping the partition table on /dev/sdb..."
# wipefs -af /dev/sdb
# echo "Partition table wiped."

# Find the first available disk (excluding sda which is likely the system disk)
DISK=$(lsblk -dpno NAME,TYPE | awk '$2=="disk" && $1!~/sda/ {print $1; exit}')
echo "Using disk: $DISK"

# Create a new partition
echo "Creating a new GPT partition on $DISK..."
parted -s "$DISK" mklabel gpt mkpart primary ext4 0% 100%
echo "Partition created."

# Wait for the system to recognize the new partition
echo "Waiting for the system to recognize the new partition..."
sleep 5

# Create filesystem
echo "Creating ext4 filesystem on ${DISK}1..."
mkfs.ext4 -F "${DISK}1"
echo "Filesystem created."

mkdir -p /store
echo "${DISK}1 /store ext4 defaults 0 2" >> /etc/fstab
mount "${DISK}1" /store

mkdir -p /store/apt /store/docker

mv /var/cache/apt /store/apt/cache
ln -s /store/apt/cache /var/cache/apt
mv /var/lib/apt/lists /store/apt/lists
ln -s /store/apt/lists /var/lib/apt/lists

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sh -c 'echo "{\"data-root\": \"/store/docker\"}" > /etc/docker/daemon.json'

groupadd docker
usermod -aG docker "$USER"
