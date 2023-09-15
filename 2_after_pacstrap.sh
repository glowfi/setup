#!/bin/bash

# READ FILES
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE=$SCRIPT_DIR/setup.conf

# Set location and Synchronize hardware clock

echo ""
echo "---------------------------------------------------------------------------------------"
echo "--------------Setting Location and Synchronizing hardware clock...---------------------"
echo "---------------------------------------------------------------------------------------"
echo ""

TIMEZONE=$(sed -n '2p' <"$CONFIG_FILE")
ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
hwclock --systohc
echo "Done setting location and synchronizing hardware clock!"

# Set Keymap

echo ""
echo "---------------------------------------------------------------------------------------"
echo "--------------Setting Keyboard layout...-----------------------------------------------"
echo "---------------------------------------------------------------------------------------"
echo ""

KEYMAP=$(sed -n '3p' <"$CONFIG_FILE")
echo "KEYMAP=$KEYMAP" >>/etc/vconsole.conf
echo "Keyboard layout set!"

# Optimize makepkg flags

echo ""
echo "--------------------------------------------------------------"
echo "--------------Optimizing makepkg flags...---------------------"
echo "--------------------------------------------------------------"
echo ""

nc=$(grep -c ^processor /proc/cpuinfo)
echo "You have " $nc" cores."
echo "-------------------------------------------------"
echo "Changing the makeflags for "$nc" cores."
TOTALMEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[ $TOTALMEM -gt 8000000 ]]; then
	sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
	echo "Changing the compression settings for "$nc" cores."
	sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
fi

# Set Locale

echo ""
echo "-----------------------------------------------------"
echo "--------------Setting Locales...---------------------"
echo "-----------------------------------------------------"
echo ""

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >>/etc/locale.conf

# Add features to pacman.conf

echo ""
echo "----------------------------------------------------------------"
echo "--------------Enabling ParallelDownloads...---------------------"
echo "----------------------------------------------------------------"
echo ""

sudo sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf
sudo pacman -Syy

# Set Hostname

echo ""
echo "------------------------------------------------------"
echo "--------------Setting hostname...---------------------"
echo "------------------------------------------------------"
echo ""

hostname=$(sed -n '10p' <"$CONFIG_FILE")
echo "$hostname" >>/etc/hostname
echo "127.0.0.1 localhost" >>/etc/hosts
echo "::1       localhost" >>/etc/hosts
echo "127.0.1.1 $hostname.localdomain $hostname" >>/etc/hosts
echo "Done setting hostname!"

# Add User

echo ""
echo "----------------------------------------------"
echo "--------------Adding user...------------------"
echo "----------------------------------------------"
echo ""

uname=$(sed -n '6p' <"$CONFIG_FILE")
fname=$(sed -n '7p' <"$CONFIG_FILE")

useradd -mG wheel $uname
usermod -c "$fname" $uname
echo "$uname ALL=(ALL) ALL" >>/etc/sudoers.d/$uname
echo "Done adding user!"

upass=$(sed -n '8p' <"$CONFIG_FILE")
rpass=$(sed -n '9p' <"$CONFIG_FILE")
echo "$uname:$upass" | chpasswd
echo "root:$rpass" | chpasswd

# Install display drivers

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing display driver...------------------------------"
echo "------------------------------------------------------------------------"
echo ""

## Auto detect GPU and install drivers

if lspci | grep -E "NVIDIA|GeForce"; then
	echo "Installing NVIDIA drivers ..."
	for i in {1..5}; do pacman -Syyy --noconfirm nvidia-dkms nvidia-utils nvidia-settings nvidia-prime && break || sleep 1; done

elif lspci | grep -E "Radeon"; then
	echo "Installing AMD Radeon drivers ..."
	for i in {1..5}; do pacman -Syyy --noconfirm xf86-video-amdgpu && break || sleep 1; done

elif lspci | grep -E "Intel Corporation UHD"; then
	echo "Installing Intel drivers ..."
	for i in {1..5}; do pacman -Syyy --noconfirm lib32-vulkan-intel && break || sleep 1; done
	for i in {1..5}; do pacman -Syyy --noconfirm libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils && break || sleep 1; done

elif lspci | grep -E "Intel Corporation HD"; then
	echo "Installing Intel drivers ..."
	for i in {1..5}; do pacman -Syyy --noconfirm lib32-vulkan-intel && break || sleep 1; done
	for i in {1..5}; do pacman -Syyy --noconfirm libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils && break || sleep 1; done

elif lspci | grep -E "Integrated Graphics Controller"; then
	echo "Installing Intel drivers ..."
	for i in {1..5}; do pacman -Syyy --noconfirm lib32-vulkan-intel && break || sleep 1; done
	for i in {1..5}; do pacman -Syyy --noconfirm libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils && break || sleep 1; done
fi

# Essential Packages

echo ""
echo "---------------------------------------------------------------------"
echo "--------------Installing Essential Packages...-----------------------"
echo "---------------------------------------------------------------------"
echo ""

driveType=$(sed -n '4p' <"$CONFIG_FILE")
if [[ "$driveType" = "ssd" ]]; then
	for i in {1..5}; do pacman -Syyy --noconfirm os-prober grub efibootmgr ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools reflector wget lsof net-tools rsync strace acpi acpi_call-dkms acpid && break || sleep 1; done

elif [[ "$driveType" = "non-ssd" ]]; then
	for i in {1..5}; do pacman -Syyy --noconfirm grub efibootmgr ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools reflector wget lsof net-tools rsync strace acpi acpi_call-dkms acpid && break || sleep 1; done

fi

# Replacement of some GNU COREUTILS and some other *nix programs

for i in {1..5}; do pacman -Syyy --noconfirm exa bat ripgrep fd bottom sad bc gum git-delta tldr duf gping tokei hyperfine && break || sleep 1; done

# GRUB

echo ""
echo "-------------------------------------------------------"
echo "--------------Installing GRUB...-----------------------"
echo "-------------------------------------------------------"
echo ""

if [[ "$driveType" = "ssd" ]]; then
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg
elif [[ "$driveType" = "non-ssd" ]]; then
	grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
	grub-mkconfig -o /boot/grub/grub.cfg
fi

# Add Modules to load at start

FS=$(sed -n '1p' <"$CONFIG_FILE")

if [[ "$FS" = "btrfs" ]]; then
	if lspci | grep -E "NVIDIA|GeForce"; then
		sed -i 's/MODULES=()/MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
		sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1"/' /etc/default/grub
		for i in {1..5}; do pacman -Syyy --noconfirm grub-btrfs && break || sleep 1; done
		grub-mkconfig -o /boot/grub/grub.cfg
		mkinitcpio -p linux-zen
		sudo systemctl enable grub-btrfsd
	elif lspci | grep -E "Radeon"; then
		sed -i 's/MODULES=()/MODULES=(btrfs amdgpu)/' /etc/mkinitcpio.conf
		for i in {1..5}; do pacman -Syyy --noconfirm grub-btrfs && break || sleep 1; done
		grub-mkconfig -o /boot/grub/grub.cfg
		mkinitcpio -p linux-zen
		sudo systemctl enable grub-btrfsd
	fi
else
	if lspci | grep -E "NVIDIA|GeForce"; then
		sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
		sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1"/' /etc/default/grub
		mkinitcpio -p linux-zen
	elif lspci | grep -E "Radeon"; then
		sed -i 's/MODULES=()/MODULES=(amdgpu)/' /etc/mkinitcpio.conf
		mkinitcpio -p linux-zen
	fi
fi

# ENCRYPTED DEVICE

encryptStatus=$(sed -n '11p' <"$CONFIG_FILE")

if [[ "$encryptStatus" = "encrypt" ]]; then

	# Add to mkinitcpio
	getReq=$(cat /etc/mkinitcpio.conf | grep -En "^HOOKS=(.+)$" | head -1 | xargs)
	getLineNumber=$(echo "$getReq" | cut -d":" -f1)
	rep=$(echo $getReq | cut -d":" -f2 | sed 's/filesystems/encrypt filesystems/g')
	sudo sed -i "${getLineNumber}s/.*/${rep}/" /etc/mkinitcpio.conf
	mkinitcpio -p linux-zen

	# Add to GRUB
	getGrubDefaultArgs=$(cat /etc/default/grub | grep -n "GRUB_CMDLINE_LINUX_DEFAULT")
	getLineNumber=$(echo "$getGrubDefaultArgs" | cut -d ":" -f1 | xargs)
	getOldArgs=$(echo "$getGrubDefaultArgs" | cut -d ":" -f2 | sed 's/.$//')

	DISK=$(sed -n '5p' <"$CONFIG_FILE")
	if [[ ${DISK} =~ "nvme" ]]; then
		UUID_CRYPT_DEVICE=$(blkid | grep "${DISK}p2" | cut -d" " -f2 | xargs)
	else
		UUID_CRYPT_DEVICE=$(blkid | grep "${DISK}2" | cut -d" " -f2 | xargs)
	fi

	cryptstring="cryptdevice=${UUID_CRYPT_DEVICE}:cryptroot root=/dev/mapper/cryptroot"
	combinedArgsWithcryptstring="${getOldArgs} ${cryptstring}\""
	sed -i "${getLineNumber}s/.*/${combinedArgsWithcryptstring}/" /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg

fi

# Disable WIFI powersaver mode

LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC

# Enable Services

echo ""
echo "---------------------------------------------------------"
echo "--------------Enabling Services...-----------------------"
echo "---------------------------------------------------------"
echo ""

systemctl enable NetworkManager
systemctl enable reflector.timer
systemctl enable acpid

# Fix an issue with Timeshift related to BTRFS

sed -i 's/subvolid.*,//' /etc/fstab

# Remove setup files

rm -rf setup
