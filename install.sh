#!/bin/bash

# Links
# https://nixos.wiki/wiki/Btrfs
# https://nixos.org/manual/nixos/stable/#sec-installation-manual-summary

help() {
echo \
"
SYNOPSIS
   $(basename "${BASH_SOURCE[0]}") [--help]

DESCRIPTION
   Partition, format, mount and then install NixOS

OPTIONS
   --device                   Device to install
   --help                     Print this help

"
}

if [ -z "$1" ] || [ "$1" = "--help" ]
    then
        help
        exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

if [ "$1" = "--device" ] && [ -n "$2" ]
    then
        DEVICE="$2"
else
    echo "Please submit a device to install"
    exit 1
fi

# nix-env -iA nixos.git

# Partitioning
printf "Partitioning ...\n"
parted "${DEVICE}" -- mklabel gpt
parted "${DEVICE}" -- mkpart root btrfs 512MB 100%
parted "${DEVICE}" -- mkpart ESP fat32 1MB 512MB
parted "${DEVICE}" -- set 2 esp on

# Formatting
printf "Formating ...\n"
mkfs.btrfs -L nixos "${DEVICE}1"
mkfs.fat -F 32 -n boot "${DEVICE}2"

## create subvolumes
printf "Creating btrfs subvolumes ...\n"
mount -L nixos /mnt  # mount /dev/disk/by-label/nixos /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@flatpak
#btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@swap
umount /mnt

# Mounting
printf "Mounting ...\n"
## btrfs subvolumes
mount -o compress=zstd,subvol=@ "${DEVICE}1" /mnt
mkdir -p /mnt/{home,nix,swap,var/log,var/lib/flatpak}
mount -o compress=zstd,noatime,subvol=@home "${DEVICE}1" /mnt/home
mount -o compress=zstd,noatime,subvol=@flatpak "${DEVICE}1" /mnt/var/lib/flatpak
#mount -o compress=zstd,noatime,subvol=@nix "${DEVICE}1" /mnt/nix
mount -o compress=zstd,noatime,subvol=@swap "${DEVICE}1" /mnt/swap
mount -o compress=zstd,noatime,subvol=@log "${DEVICE}1" /mnt/var/log
#btrfs filesystem mkswapfile --size 8G --uuid clear /mnt/swap/swapfile
#swapon /mnt/swap/swapfile

## boot partition
mkdir -p /mnt/boot
mount -L boot /mnt/boot  # mount /dev/disk/by-label/boot /mnt/boot

# Generate nix config
nixos-generate-config --root /mnt

printf "Downloading my configuration.nix ...\n"
sudo curl -L -s https://github.com/queeup/nixos-portable/raw/main/configuration.nix \
          -o /mnt/etc/nixos/configuration.nix
sudo curl -L -s https://github.com/queeup/nixos-portable/raw/main/filesystems.nix \
          -o /mnt/etc/nixos/filesystems.nix
sudo curl -L -s https://github.com/queeup/nixos-portable/raw/main/gnome.nix \
          -o /mnt/etc/nixos/gnome.nix
sudo curl -L -s https://github.com/queeup/nixos-portable/raw/main/systemd.nix \
          -o /mnt/etc/nixos/systemd.nix
sudo curl -L -s https://github.com/queeup/nixos-portable/raw/main/unstable-pkgs.nix \
          -o /mnt/etc/nixos/unstable-pkgs.nix
sudo curl -L -s https://github.com/queeup/nixos-portable/raw/main/users.nix \
          -o /mnt/etc/nixos/users.nix

printf "Installing NixOS\n"
nixos-install --no-root-passwd