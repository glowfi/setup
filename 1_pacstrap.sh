#!/bin/bash

# Setup
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/helpers/pkg_installer.sh"
source "${SCRIPT_DIR}/helpers/mirror_syncer.sh"
source "${SCRIPT_DIR}/helpers/config_loader.sh"
source "${SCRIPT_DIR}/helpers/get_partition_name.sh"
source "${SCRIPT_DIR}/helpers/header.sh"
load_config "${SCRIPT_DIR}/setup.conf"
require_config FILESYSTEM DISK DISK_TYPE DISK_ENCRYPT DISTRO_TYPE KERNEL
[[ "$DISK_ENCRYPT" == "encrypt" ]] && require_config LUKS_PASSWORD

# Sync Mirrors
header "Setting up mirrors for faster downloads"
sync_mirror "$DISTRO_TYPE"

# Install necessary initial packages
if [[ "$DISTRO_TYPE" == "arch" ]]; then
	install "reflector gptfdisk parted git" "pac"
else
	install "gptfdisk parted git" "pac"
fi

# Disk Partitioning
header "Cleaning up any state from a previous run"
umount -R /mnt 2>/dev/null || true
cryptsetup close cryptroot 2>/dev/null || true

header "Auto partitioning the disk"
EFI_PART=$(part "${DISK}" 1)
ROOT_PART=$(part "${DISK}" 2)
wipefs -af "$DISK"
sgdisk --zap-all --clear "$DISK"
partprobe "$DISK"

root_type=8300
[[ "$DISK_ENCRYPT" == "encrypt" ]] && root_type=8309

sgdisk -n 1:0:+1G -t 1:ef00 -c 1:EFI "$DISK"
sgdisk -n 2:0:0 -t 2:"$root_type" -c 2:"Arch Linux" "$DISK"
partprobe "$DISK"

ROOT_DEV="$ROOT_PART"

if [[ "$DISK_ENCRYPT" == "encrypt" ]]; then
	header "Setting up LUKS"
	perf_flags=()
	[[ "$DISK_TYPE" == "ssd" ]] && perf_flags=(--perf-no_read_workqueue --perf-no_write_workqueue)

	echo "${LUKS_PASSWORD}" | cryptsetup luksFormat --batch-mode "${perf_flags[@]}" \
		--type luks1 -c aes-xts-plain64 -s 256 --use-random "$ROOT_PART"

	open_flags=("${perf_flags[@]}")
	[[ "$DISK_TYPE" == "ssd" ]] && open_flags+=(--allow-discards)
	echo "${LUKS_PASSWORD}" | cryptsetup luksOpen "${open_flags[@]}" "$ROOT_PART" cryptroot

	ROOT_DEV="/dev/mapper/cryptroot"
fi

header "Formatting disk"
mkfs.fat -F32 "$EFI_PART"
case "$FILESYSTEM" in
btrfs) mkfs.btrfs -f "$ROOT_DEV" ;;
ext4) mkfs.ext4 -f "$ROOT_DEV" ;;
*)
	echo "Unsupported filesystem: $FILESYSTEM" >&2
	exit 1
	;;
esac

header "Mounting disk"
if [[ "$FILESYSTEM" == "btrfs" ]]; then
	mount "$ROOT_DEV" /mnt
	for subvol in @ @home @snapshots @var_log; do
		btrfs su cr "/mnt/$subvol"
	done
	umount /mnt

	btrfs_opts="noatime,compress-force=zstd,commit=120,space_cache=v2,ssd,discard=async"
	mount -o "${btrfs_opts},subvol=@" "$ROOT_DEV" /mnt
	mkdir -p /mnt/{home,.snapshots,var_log}
	mount -o "${btrfs_opts},subvol=@home" "$ROOT_DEV" /mnt/home
	mount -o "${btrfs_opts},subvol=@snapshots" "$ROOT_DEV" /mnt/.snapshots
	mount -o "${btrfs_opts},subvol=@var_log" "$ROOT_DEV" /mnt/var_log
else
	mount -t ext4 "$ROOT_DEV" /mnt
fi

mkdir -p /mnt/boot/efi
mount "$EFI_PART" /mnt/boot/efi

# Bootstrap base system
header "Bootstrap base system"

proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
pkgs=(base base-devel "$KERNEL" "${KERNEL}-headers" linux-firmware git vim)

case "$proc_type" in
GenuineIntel)
	ucode_pkg="intel-ucode"
	echo -e "\e[34mInstalling Intel microcode ...\e[0m"
	;;
AuthenticAMD)
	ucode_pkg="amd-ucode"
	echo -e "\e[31mInstalling AMD microcode ...\e[0m"
	;;
*)
	ucode_pkg=""
	echo "Unrecognized CPU vendor '${proc_type}' - skipping microcode package."
	;;
esac

[[ "$FILESYSTEM" == "btrfs" ]] && pkgs+=(btrfs-progs)
[[ -n "$ucode_pkg" ]] && pkgs+=("$ucode_pkg")

if [[ "$DISTRO_TYPE" == "artix" ]]; then
	bootstrap_cmd="basestrap"
	pkgs+=(openrc elogind-openrc)
else
	bootstrap_cmd="pacstrap"
fi

bootstrap_ok=false
for i in {1..5}; do
	if "$bootstrap_cmd" /mnt "${pkgs[@]}"; then
		bootstrap_ok=true
		break
	fi
	sleep 1
done

if [[ "$bootstrap_ok" != true ]]; then
	echo "Error: failed to bootstrap base system after 5 attempts" >&2
	exit 1
fi

# Generate disk partition table
header "Generating disk partition table"
if [[ "$DISTRO_TYPE" == "arch" ]]; then
	genfstab -U /mnt >/mnt/etc/fstab
else
	fstabgen -U /mnt >/mnt/etc/fstab
fi
