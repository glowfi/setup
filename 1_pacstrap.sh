#!/bin/bash

# FILES
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE=$SCRIPT_DIR/setup.conf

# Source Helper
source "$SCRIPT_DIR/helper.sh"

# SYNCHRONIZE

echo ""
echo -e "-------------------------------------------------------------------------"
echo -e "-----------Setting up mirrors for faster downloads-----------------------"
echo -e "-------------------------------------------------------------------------"
echo ""

_distroType=$(sed '$!d' "$CONFIG_FILE")

if [[ "$_distroType" = "artix" ]]; then
	sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
	sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf
	sudo pacman -Syy

	install "artix-archlinux-support" "pac"
	sudo tee -a /etc/pacman.conf <<EOF

[extra]
Include = /etc/pacman.d/mirrorlist-arch
EOF
	sudo pacman-key --populate archlinux
	sudo pacman -Syy
	install "reflector" "pac"
	reflector --verbose -c DE --latest 5 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist-arch
	sudo pacman -Syy
	install "gptfdisk" "pac"
else
	timedatectl set-ntp true
	sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
	sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf
	reflector --verbose -c DE --latest 5 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
	install "archlinux-keyring" "pac"
	pacman -Syyy
fi

# PARTITIONING

echo ""
echo "--------------------------------------------------"
echo "-------Auto partitioning the disk...--------------"
echo "--------------------------------------------------"
echo ""

# Encryption status
encryptStatus=$(sed -n '11p' <"$CONFIG_FILE")

# Disk to operate
DISK=$(sed -n '5p' <"$CONFIG_FILE")

# Delete old partition layout and re-read partition table
wipefs -af "${DISK}"
sgdisk --zap-all --clear "${DISK}"
partprobe "${DISK}"

# Partition disk and re-read partition table
if [[ "$encryptStatus" = "encrypt" ]]; then
	sgdisk -n 1:0:+1G -t 1:ef00 -c 1:EFI "${DISK}"
	sgdisk -n 2:0:0 -t 2:8309 -c 2:"Arch Linux" "${DISK}"
else
	sgdisk -n 1:0:+1G -t 1:ef00 -c 1:EFI "${DISK}"
	sgdisk -n 2:0:0 -t 2:8300 -c 2:"Arch Linux" "${DISK}"
fi
partprobe "${DISK}"

if [[ "$encryptStatus" = "encrypt" ]]; then

	# LUKS Setup

	echo ""
	echo "-----------------------------------------------------"
	echo "--------------LUKS Setup...--------------------------"
	echo "-----------------------------------------------------"
	echo ""

	# Encrypt and open LUKS partition
	LUKS_PASSWORD=$(sed -n '12p' <"$CONFIG_FILE")

	# ADD FLAGS FOR SSD PERFORMANCE
	driveType=$(sed -n '4p' <"$CONFIG_FILE")
	if [[ "$driveType" = "ssd" ]]; then
		if [[ ${DISK} =~ "nvme" ]]; then
			echo "${LUKS_PASSWORD}" | cryptsetup luksFormat --perf-no_read_workqueue --perf-no_write_workqueue --type luks1 -c aes-xts-plain64 -s 256 --use-random "${DISK}p2"
			echo "${LUKS_PASSWORD}" | cryptsetup luksOpen --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue "${DISK}p2" cryptroot
		else
			echo "${LUKS_PASSWORD}" | cryptsetup luksFormat --perf-no_read_workqueue --perf-no_write_workqueue --type luks1 -c aes-xts-plain64 -s 256 --use-random "${DISK}2"
			echo "${LUKS_PASSWORD}" | cryptsetup luksOpen --allow-discards --perf-no_read_workqueue --perf-no_write_workqueue "${DISK}2" cryptroot
		fi
	else
		echo "${LUKS_PASSWORD}" | cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 256 --use-random "${DISK}2"
		echo "${LUKS_PASSWORD}" | cryptsetup luksOpen "${DISK}2" cryptroot
	fi

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
			mkfs.btrfs -f /dev/mapper/cryptroot
		else
			mkfs.fat -F32 "${DISK}1"
			mkfs.btrfs -f /dev/mapper/cryptroot
		fi

	elif [[ "$FS" = "ext4" ]]; then
		if [[ ${DISK} =~ "nvme" ]]; then
			mkfs.fat -F32 "${DISK}p1"
			mkfs.ext4 -f /dev/mapper/cryptroot
		else
			mkfs.fat -F32 "${DISK}1"
			mkfs.ext4 -f /dev/mapper/cryptroot
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
			mount /dev/mapper/cryptroot /mnt
			btrfs su cr /mnt/@
			btrfs su cr /mnt/@home
			btrfs su cr /mnt/@snapshots
			btrfs su cr /mnt/@var_log
			umount /mnt

			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
			mkdir -p /mnt/{home,.snapshots,var_log}
			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@var_log /dev/mapper/cryptroot /mnt/var_log
			mkdir -p /mnt/boot/efi
			mount "${DISK}p1" /mnt/boot/efi
		else
			mount /dev/mapper/cryptroot /mnt
			btrfs su cr /mnt/@
			btrfs su cr /mnt/@home
			btrfs su cr /mnt/@snapshots
			btrfs su cr /mnt/@var_log
			umount /mnt

			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@ /dev/mapper/cryptroot /mnt
			mkdir -p /mnt/{home,.snapshots,var_log}
			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@home /dev/mapper/cryptroot /mnt/home
			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@var_log /dev/mapper/cryptroot /mnt/var_log
			mkdir -p /mnt/boot/efi
			mount "${DISK}1" /mnt/boot/efi
		fi
	elif [[ "$FS" = "ext4" ]]; then
		if [[ ${DISK} =~ "nvme" ]]; then
			mount -t ext4 /dev/mapper/cryptroot /mnt
			umount /mnt

			mkdir -p /mnt/boot/efi
			mount "${DISK}p1" /mnt/boot/efi
		else
			mount -t ext4 /dev/mapper/cryptroot /mnt
			umount /mnt

			mkdir -p /mnt/boot/efi
			mount "${DISK}1" /mnt/boot/efi
		fi
	fi

elif [[ "$encryptStatus" = "noencrypt" ]]; then

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
			btrfs su cr /mnt/@home
			btrfs su cr /mnt/@snapshots
			btrfs su cr /mnt/@var_log
			umount /mnt

			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@ "${DISK}2" /mnt
			mkdir -p /mnt/{home,.snapshots,var_log}
			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@home "${DISK}2" /mnt/home
			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@snapshots "${DISK}2" /mnt/.snapshots
			mount -o noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async,subvol=@var_log "${DISK}2" /mnt/var_log
			mkdir -p /mnt/boot/efi
			mount "${DISK}1" /mnt/boot/efi
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

			mkdir -p /mnt/boot/efi
			mount "${DISK}1" /mnt/boot/efi
		fi
	fi
fi

# INSTALL BASE SYSTEM

if [[ "$_distroType" = "artix" ]]; then
	strapType="Base"
else
	strapType="Pac"
fi

echo ""
echo "----------------------------------------------------"
echo "--------------${strapType}strapping...--------------"
echo "----------------------------------------------------"
echo ""

## Auto Detect Intel or AMD CPU

proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
if [[ ${proc_type} =~ "GenuineIntel" ]]; then
	echo ""
	echo -e "\e[34mInstalling Intel microcode ...\e[0m"
	echo ""
	if [[ "$_distroType" = "artix" ]]; then
		for i in {1..5}; do basestrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware intel-ucode btrfs-progs git vim openrc elogind-openrc && break || sleep 1; done
	else
		for i in {1..5}; do pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware intel-ucode btrfs-progs git vim && break || sleep 1; done
	fi

elif [[ ${proc_type} =~ "AuthenticAMD" ]]; then
	echo ""
	echo -e "\e[31mInstalling AMD microcode ...\e[0m"
	echo ""
	if [[ "$_distroType" = "artix" ]]; then
		for i in {1..5}; do basestrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware amd-ucode btrfs-progs git vim openrc elogind-openrc && break || sleep 1; done
	else
		for i in {1..5}; do pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware amd-ucode btrfs-progs git vim && break || sleep 1; done
	fi

fi

# GENERATE UUID OF THE DISKS

if [[ "$_distroType" = "artix" ]]; then
	fstabgen -U /mnt >>/mnt/etc/fstab
else
	genfstab -U /mnt >>/mnt/etc/fstab
fi

# COPY SCRIPTS TO THE MOUNT DIRECTORY

cp -r "$SCRIPT_DIR" /mnt/
