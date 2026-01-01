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
printf "\nPartitioning ...\n"
parted "${DEVICE}" -- mklabel gpt
parted "${DEVICE}" -- mkpart root btrfs 512MB 100%
parted "${DEVICE}" -- mkpart ESP fat32 1MB 512MB
parted "${DEVICE}" -- set 2 esp on

# Formatting
printf "\nFormating ...\n"
mkfs.btrfs -L nixos "${DEVICE}1"
mkfs.fat -F 32 -n boot "${DEVICE}2"

## create subvolumes
printf "\nCreating btrfs subvolumes ...\n"
mount -L nixos /mnt  # mount /dev/disk/by-label/nixos /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@var
chattr +C /mnt/@var  # disable CoW
umount /mnt

# Mounting
printf "\nMounting ...\n"
## btrfs subvolumes
mount -o compress=zstd,subvol=@ "${DEVICE}1" /mnt
mkdir -p /mnt/{home,nix,swap,var}
mount -o compress=zstd,noatime,subvol=@home "${DEVICE}1" /mnt/home
mount -o compress=zstd,noatime,subvol=@nix "${DEVICE}1" /mnt/nix
mount -o compress=zstd,noatime,subvol=@swap "${DEVICE}1" /mnt/swap
mount -o noatime,subvol=@var "${DEVICE}1" /mnt/var  # nodatacow with chattr +C /mnt/@var
btrfs filesystem mkswapfile --size 4G --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

## boot partition
mkdir -p /mnt/boot
mount -o umask=077 -L boot /mnt/boot  # mount /dev/disk/by-label/boot /mnt/boot

# Generate nix config
nixos-generate-config --root /mnt

printf "\nDownloading my configuration.nix ...\n"
sudo curl --silent --create-dirs --remote-name --location --output-dir /mnt/etc/nixos \
    "https://github.com/queeup/nixos-portable/raw/main/{configuration,filesystems,gnome,systemd,unstable-pkgs,users}.nix"

printf "\nInstalling NixOS\n"
nixos-install --no-root-passwd