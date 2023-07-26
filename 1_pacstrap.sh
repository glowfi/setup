#!/bin/bash

# FILES
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE=$SCRIPT_DIR/setup.conf

# SYNCHRONIZE

echo ""
echo -e "-------------------------------------------------------------------------"
echo -e "-----------Setting up mirrors for faster downloads-----------------------"
echo -e "-------------------------------------------------------------------------"
echo ""

timedatectl set-ntp true
sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf
reflector --verbose -c DE --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
pacman -S --noconfirm archlinux-keyring
pacman -Syyy

# ALIGN DISK

echo ""
echo "--------------------------------------------------"
echo "-------Aligning new GPT partition...--------------"
echo "--------------------------------------------------"
echo ""

DISK=$(sed -n '5p' <"$CONFIG_FILE")

sgdisk -Z ${DISK}
sgdisk -a 2048 -o ${DISK}

# PARTITION

echo ""
echo "--------------------------------------------------"
echo "-------Auto partitioning the disk...--------------"
echo "--------------------------------------------------"
echo ""

(
	echo n
	echo
	echo
	echo +300M
	echo ef00
	echo n
	echo
	echo
	echo
	echo
	echo c
	echo 1
	echo "EFI"
	echo c
	echo 2
	echo "Arch Linux"
	echo w
	echo Y
) | gdisk ${DISK}

# FORMAT

echo ""
echo "-----------------------------------------------------"
echo "--------------Formatting disk...---------------------"
echo "-----------------------------------------------------"
echo ""

FS=$(sed -n '1p' <"$CONFIG_FILE")

if [[ "$FS" = "btrfs" ]]; then
	if [[ ${DISK} =~ "nvme" ]]; then
		mkfs.fat -F32 "${DISK}p1"
		mkfs.btrfs -f "${DISK}p2"
	else
		mkfs.fat -F32 "${DISK}1"
		mkfs.btrfs -f "${DISK}2"
	fi

elif [[ "$FS" = "ext4" ]]; then
	if [[ ${DISK} =~ "nvme" ]]; then
		mkfs.fat -F32 "${DISK}p1"
		mkfs.ext4 -f "${DISK}p2"
	else
		mkfs.fat -F32 "${DISK}1"
		mkfs.ext4 -f "${DISK}2"
	fi

fi

# MOUNT

echo ""
echo "-----------------------------------------------------"
echo "--------------Mounting disk...-----------------------"
echo "-----------------------------------------------------"
echo ""

if [[ "$FS" = "btrfs" ]]; then
	if [[ ${DISK} =~ "nvme" ]]; then
		mount "${DISK}p2" /mnt
		btrfs su cr /mnt/@
		btrfs su cr /mnt/@home
		btrfs su cr /mnt/@snapshots
		btrfs su cr /mnt/@var_log
		umount /mnt

		mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@ "${DISK}p2" /mnt
		mkdir -p /mnt/{home,.snapshots,var_log}
		mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@home "${DISK}p2" /mnt/home
		mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@snapshots "${DISK}p2" /mnt/.snapshots
		mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@var_log "${DISK}p2" /mnt/var_log
		mkdir -p /mnt/boot/efi
		mount "${DISK}p1" /mnt/boot/efi
	else
		mount "${DISK}2" /mnt
		btrfs su cr /mnt/@
		umount /mnt

		mount -o noatime,compress-force=zstd,space_cache=v2,subvol=@ "${DISK}2" /mnt
		mkdir -p /mnt/boot
		mount "${DISK}1" /mnt/boot
	fi
elif [[ "$FS" = "ext4" ]]; then
	if [[ ${DISK} =~ "nvme" ]]; then
		mount -t ext4 "${DISK}p2" /mnt
		umount /mnt

		mkdir -p /mnt/boot/efi
		mount "${DISK}p1" /mnt/boot/efi
	else
		mount -t ext4 "${DISK}2" /mnt
		umount /mnt

		mkdir -p /mnt/boot
		mount "${DISK}1" /mnt/boot
	fi
fi

# INSTALL BASE SETUP

echo ""
echo "----------------------------------------------------"
echo "--------------Pacstrapping...-----------------------"
echo "----------------------------------------------------"
echo ""

## Determine Intel or AMD CPU
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
if [[ ${proc_type} =~ "GenuineIntel" ]]; then
	echo ""
	echo "Installing Intel microcode ..."
	echo ""
	for i in {1..5}; do pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware intel-ucode btrfs-progs git vim && break || sleep 1; done
elif [[ ${proc_type} =~ "AuthenticAMD" ]]; then
	echo ""
	echo "Installing AMD microcode ..."
	echo ""
	for i in {1..5}; do pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware amd-ucode btrfs-progs git vim && break || sleep 1; done

fi

# GENERATE UUID OF THE DISKS

genfstab -U /mnt >>/mnt/etc/fstab

# COPY SCRIPTS TO THE MOUNT DIRECTORY

cp -r "$SCRIPT_DIR" /mnt/
