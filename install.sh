#!/usr/bin/env bash

# Links
# https://nixos.wiki/wiki/Btrfs
# https://nixos.org/manual/nixos/stable/#sec-installation-manual-summary

DEVICE=""
URL="https://github.com/queeup/nixos-mediacenter/raw/main"

function help() {
echo \
"
SYNOPSIS
   $(basename "${BASH_SOURCE[0]}") [--device] [--url] [--help]

DESCRIPTION
   Partition, format, mount and then install NixOS

OPTIONS
   --device                   Device to install
   --url                      Base URL to download configuration files from (Default: https://github.com/queeup/nixos-portable/raw/main)
   --help                     Print this help
"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --device)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: --device requires a device path (e.g., /dev/sda)"
                exit 1
            fi
            DEVICE="$2"
            shift 2
            ;;
        --url)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: --url requires a valid URL (e.g., http://192.168.1.232:9999)"
                exit 1
            fi
            URL="$2"
            shift 2
            ;;
        --help)
            help
            exit 0
            ;;
        *)
            echo "Unknown argument: $1"
            help
            exit 1
            ;;
    esac
done

if [ -z "$DEVICE" ]; then
    echo "Please submit a device to install (e.g., --device /dev/sda)"
    help
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Partitioning
printf "\nPartitioning %s ...\n" "${DEVICE}"
parted "${DEVICE}" -- mklabel gpt
parted "${DEVICE}" -- mkpart root btrfs 512MB 100%
parted "${DEVICE}" -- mkpart ESP fat32 1MB 512MB
parted "${DEVICE}" -- set 2 esp on
partprobe "${DEVICE}"
udevadm settle

# Formatting
printf "\nFormatting partitions on %s ...\n" "${DEVICE}"
mkfs.btrfs -L nixos "/dev/disk/by-partlabel/root"
mkfs.fat -F 32 -n boot "/dev/disk/by-partlabel/ESP"

## create subvolumes
printf "\nCreating btrfs subvolumes ...\n"
mount "/dev/disk/by-partlabel/root" /mnt  # mount -L nixos /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
btrfs subvolume create /mnt/@swap
btrfs subvolume create /mnt/@var
chattr +C /mnt/@nix  # disable CoW
chattr +C /mnt/@var  # disable CoW
chattr +C /mnt/@swap  # disable CoW
umount /mnt

# Mounting
printf "\nMounting partitions ...\n"
## btrfs subvolumes
mount -o subvol=@,compress=zstd,,noatime "/dev/disk/by-partlabel/root" /mnt
mkdir -p /mnt/{home,nix,swap,var}
mount -o subvol=@home,compress=zstd,noatime "/dev/disk/by-partlabel/root" /mnt/home
mount -o subvol=@nix,noatime "/dev/disk/by-partlabel/root" /mnt/nix  # nodatacow with chattr +C /mnt/@nix
mount -o subvol=@swap,noatime "/dev/disk/by-partlabel/root" /mnt/swap  # nodatacow with chattr +C /mnt/@swap
mount -o subvol=@var,noatime "/dev/disk/by-partlabel/root" /mnt/var  # nodatacow with chattr +C /mnt/@var
# filesystem.nix swapDevices.size taking care of swap file
# btrfs filesystem mkswapfile --size 8G --uuid clear /mnt/swap/swapfile
# swapon /mnt/swap/swapfile

## boot partition
mkdir -p /mnt/boot
mount -o umask=0077 "/dev/disk/by-partlabel/ESP" /mnt/boot  # mount -o umask=0077 -L boot /mnt/boot

# Generate nix config
# nixos-generate-config --root /mnt

printf "\nDownloading and generating configuration files from %s...\n" "${URL}"
curl --silent --create-dirs --remote-name --location --output-dir /mnt/etc/nixos \
    "${URL}/{configuration,filesystems,gnome,systemd,unstable-pkgs,users}.nix"

nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hardware-configuration.nix

printf "\nInstalling NixOS\n"
nixos-install --no-root-passwd
