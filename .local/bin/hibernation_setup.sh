#!/usr/bin/env bash
#

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root or sudo."
	exit 1
fi

set -euo pipefail

trap 'echo "Error on line $LINENO. Exit code: $?" >&2' ERR

log_error() {
	echo "Error: $1" >&2
}

swapfile_size() {
    local MEM=$(free -g | awk '$1=="Mem:" {print $2}')
 #    local SWAP
 #    if [ "$MEM" -lt 16 ]; then
 #        SWAP=$MEM
 #    else
 #        SWAP=$(echo "$MEM + ($MEM * 0.2)" | bc)
 #         SWAP=$(echo 20 | bc)
 #    fi
 #    echo "$SWAP"G
    echo "$MEM"G
}

echo "Creating backup of /etc/fstab: /etc/fstab.backup"
cp /etc/fstab /etc/fstab.backup
echo "Removing existing swap from /etc/fstab"
sed -i '/swap/s/^/#/' /etc/fstab

echo "Create new swapfile..."
SWAP_SIZE=$(swapfile_size)
fallocate -l $SWAP_SIZE /swapfile || log_error "Failed to create swap file"
chmod 0600 /swapfile
mkswap /swapfile || log_error "mkswap failed"
swapon /swapfile || log_error "swapon failed"

echo "Make the swapfile permanent..."

echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

ROOT_UUID=$(blkid -s UUID -o value /dev/$(lsblk -nlo NAME,MOUNTPOINT | awk '$2=="/" {print $1}'))

SWAP_OFFSET=$(filefrag -v /swapfile | grep -A1 "physical_offset" | tail -1 | awk '{print $4}' | cut -d'.' -f1)

echo "Update GRUB Config..."

sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="quiet splash resume=UUID='$ROOT_UUID' resume_offset='$SWAP_OFFSET'"' /etc/default/grub || log_error "Failed to modify grub file"

update-grub || log_error "update-grub failed"

echo "Updating initramfs..."
echo 'RESUME=/swapfile' | tee /etc/initramfs-tools/conf.d/resume
update-initramfs -u -k all

echo "Hibernation setup complete. Please reboot your system for changes to take effect."
