#!/bin/bash

# Setup
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/helpers/mirror_syncer.sh"
source "${SCRIPT_DIR}/helpers/pkg_installer.sh"
source "${SCRIPT_DIR}/helpers/config_loader.sh"
source "${SCRIPT_DIR}/helpers/get_partition_name.sh"
source "${SCRIPT_DIR}/helpers/header.sh"
source "${SCRIPT_DIR}/helpers/detect_gpu.sh"
load_config "${SCRIPT_DIR}/setup.conf"
require_config TIMEZONE KEYMAP FILESYSTEM DISK DISK_TYPE DISK_ENCRYPT USERNAME FULLNAME \
	USER_PASSWORD ROOT_PASSWORD HOSTNAME DISTRO_TYPE
[[ "$DISK_ENCRYPT" == "encrypt" ]] && require_config LUKS_PASSWORD

# Set location and Synchronize hardware clock
header "Setting location and synchronizing hardware clock"
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
if [[ "$DISTRO_TYPE" == "artix" ]]; then
	install "openntpd-openrc" "pac"
	rc-update add ntpd 2>/dev/null || true
fi
hwclock --systohc

# Set Keymap
header "Setting keyboard layout"
echo "KEYMAP=${KEYMAP}" >/etc/vconsole.conf

# Optimize makepkg flags
header "Optimizing makepkg flags"
cores=$(grep -c ^processor /proc/cpuinfo)
total_mem_kb=$(grep -i 'memtotal' /proc/meminfo | grep -o '[[:digit:]]*')
echo "Detected ${cores} cores."
if ((total_mem_kb > 8000000)); then
	sed -i -E "s/^#?MAKEFLAGS=.*/MAKEFLAGS=\"-j${cores}\"/" /etc/makepkg.conf
	sed -i -E "s/^#?COMPRESSXZ=.*/COMPRESSXZ=(xz -c -T ${cores} -z -)/" /etc/makepkg.conf
fi

# Set Locale
header "Setting locale"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

# Set Hostname
header "Setting hostname"
echo "$HOSTNAME" >/etc/hostname
cat >/etc/hosts <<-EOF
	127.0.0.1 localhost
	::1       localhost
	127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

# Add User
header "Adding user"
if ! id -u "$USERNAME" &>/dev/null; then
	useradd -mG wheel "$USERNAME"
	usermod -c "$FULLNAME" "$USERNAME"
	echo "$USERNAME ALL=(ALL) ALL" >"/etc/sudoers.d/${USERNAME}"
	echo "${USERNAME}:${USER_PASSWORD}" | chpasswd
	echo "root:${ROOT_PASSWORD}" | chpasswd
	usermod -aG video,input "$USERNAME"
else
	echo "User ${USERNAME} already exists, skipping useradd."
fi

# Configure pacman
header "Setting up mirrors for faster downloads"
sync_mirror "$DISTRO_TYPE"

# Install display drivers
header "Installing display driver"
gpu=$(detect_gpu)

case "$gpu" in
nvidia)
	echo -e "\e[32mInstalling NVIDIA graphics drivers ...\e[0m"
	install "nvtop" "pac"
	install "nvidia-dkms nvidia-utils nvidia-settings nvidia-prime" "pac"
	;;
amd)
	echo -e "\e[31mInstalling AMD Radeon graphics drivers ...\e[0m"
	install "xf86-video-amdgpu" "pac"
	;;
intel)
	echo -e "\e[34mInstalling Intel graphics drivers ...\e[0m"
	install "libva-intel-driver libvdpau-va-gl vulkan-intel libva-utils" "pac"
	;;
esac

# Essential Packages
header "Installing essential packages"
pkgs=(
	cmake extra-cmake-modules ninja meson
	os-prober grub efibootmgr ntfs-3g
	cracklib pacman-contrib
	network-manager-applet wireless_tools wpa_supplicant net-tools dnsutils usbutils gperftools tcpdump
	dialog mtools dosfstools gptfdisk
	rsync reflector wget less
	lsof strace bc
	eza bat ripgrep fd btop sad git-delta tldr duf gping
	tokei hyperfine
)
if [[ "$DISTRO_TYPE" == "arch" ]]; then
	pkgs+=(networkmanager syslog-ng logrotate)
else
	pkgs+=(
		syslog-ng-openrc networkmanager-openrc backlight-openrc openssh-openrc
		syslog-ng logrotate
		libdbi librabbitmq-c mongo-c-driver libesmtp hiredis libmaxminddb
		net-snmp librdkafka python-ply
		dbus-openrc
	)
fi
install "${pkgs[*]}" "pac"

# Configure grub bootloader
header "Installing bootloader packages"
install "grub efibootmgr os-prober" "pac"
[[ "$DISK_ENCRYPT" == "encrypt" ]] && install "cryptsetup" "pac"

header "Configuring GRUB defaults"
if [[ "$DISK_ENCRYPT" == "encrypt" ]]; then
	grep -q '^GRUB_ENABLE_CRYPTODISK=' /etc/default/grub &&
		sed -i 's/^GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/' /etc/default/grub ||
		echo "GRUB_ENABLE_CRYPTODISK=y" >>/etc/default/grub
fi
sed -i 's/ quiet//' /etc/default/grub
sed -i "s/^GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080/" /etc/default/grub

# Configure MODULES, FILES, HOOKS in mkinitcpio
header "Configuring mkinitcpio"
gpu=$(detect_gpu)
case "$gpu" in
nvidia) gpu_modules="nvidia nvidia_modeset nvidia_uvm nvidia_drm" ;;
amd) gpu_modules="amdgpu" ;;
esac

modules="$gpu_modules"
[[ "$FILESYSTEM" == "btrfs" ]] && modules="btrfs ${modules}"
modules="${modules% }"
sed -i "s/^MODULES=.*/MODULES=(${modules})/" /etc/mkinitcpio.conf

if [[ "$DISK_ENCRYPT" == "encrypt" ]]; then
	sed -i 's#^FILES=.*#FILES=(/root/cryptlvm.keyfile)#' /etc/mkinitcpio.conf
	sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap microcode modconf kms consolefont block encrypt filesystems fsck)/' \
		/etc/mkinitcpio.conf
fi

# LUKS keyfile creation and configure grub for encryption
if [[ "$DISK_ENCRYPT" == "encrypt" ]]; then
	header "Configuring encrypted boot"
	root_part=$(part "${DISK}" 2)
	if [[ ! -f /root/cryptlvm.keyfile ]]; then
		dd bs=512 count=4 if=/dev/random of=/root/cryptlvm.keyfile iflag=fullblock
		chmod 000 /root/cryptlvm.keyfile
	fi

	if ! cryptsetup luksOpen --test-passphrase --key-file=/root/cryptlvm.keyfile "$root_part" 2>/dev/null; then
		printf '%s' "${LUKS_PASSWORD}" | cryptsetup -v luksAddKey "$root_part" /root/cryptlvm.keyfile
	else
		echo "Keyfile already registered for ${root_part}, skipping luksAddKey."
	fi

	uuid_crypt_device=$(blkid -s UUID -o value "$root_part")
	cryptstring="cryptdevice=UUID=${uuid_crypt_device}:cryptroot"
	[[ "$DISK_TYPE" == "ssd" ]] && cryptstring+=":allow-discards"
	cryptstring+=" root=/dev/mapper/cryptroot cryptkey=rootfs:/root/cryptlvm.keyfile"

	sed -i "s#^GRUB_CMDLINE_LINUX_DEFAULT=.*#GRUB_CMDLINE_LINUX_DEFAULT=\"${cryptstring}\"#" /etc/default/grub
fi

# Enable nvidia drm modeset in grub
gpu=$(detect_gpu)
if [[ "$gpu" == "nvidia" ]] && ! grep -q 'nvidia-drm.modeset=1' /etc/default/grub; then
	header "Enabling NVIDIA DRM modeset"
	sed -i -E 's/^GRUB_CMDLINE_LINUX_DEFAULT="(.*)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia-drm.modeset=1"/' /etc/default/grub
fi

# Install GRUB
header "Installing GRUB"
if [[ -f /boot/efi/EFI/GRUB/grubx64.efi ]]; then
	echo "GRUB EFI already installed, skipping."
else
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck --modules=tpm --disable-shim-lock
fi

# Regenerate initramfs
header "Regenerating initramfs"
mkinitcpio -P

# Theme Grub
header "Installing GRUB theme"
theme_dir="/test/minimal-grub-theme"
for i in {1..5}; do
	rm -rf "$theme_dir"
	mkdir -p "$theme_dir"
	git clone https://github.com/glowfi/minimal-grub-theme "$theme_dir" && break
	sleep 1
done
make install -C "$theme_dir"
rm -rf /test

header "Generating GRUB config"
grub-mkconfig -o /boot/grub/grub.cfg

# Enable sudo insults on wrong pasword
sudoers_file="/etc/sudoers"
if ! grep 'Defaults insults' "$sudoers_file"; then
	echo 'Defaults insults' >>"$sudoers_file"
fi

# Disable wifi powersaving
header "Disabling wifi powersave"
mkdir -p /etc/NetworkManager/conf.d
cat >/etc/NetworkManager/conf.d/wifi-powersave.conf <<-EOF
	[connection]
	wifi.powersave = 2
EOF
chmod 0644 /etc/NetworkManager/conf.d/wifi-powersave.conf

# Fix fstab for timeshift
if [[ "$FILESYSTEM" == "btrfs" ]]; then
	header "Fixing fstab for Timeshift"
	sed -i -E 's/subvolid=[^,]*,?//' /etc/fstab
fi

# Enable services
header "Enabling services"
if [[ "$DISTRO_TYPE" == "arch" ]]; then
	for svc in NetworkManager reflector.timer; do
		systemctl enable "$svc"
	done
else
	for svc in NetworkManager backlight syslog-ng dbus; do
		rc-update add "$svc" default
	done
fi
