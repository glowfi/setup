#!/bin/bash

# READ FILES
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE=$SCRIPT_DIR/setup.conf

# Source Helper
source "$SCRIPT_DIR/helper.sh"

# Set location and Synchronize hardware clock

echo ""
echo "---------------------------------------------------------------------------------------"
echo "--------------Setting Location and Synchronizing hardware clock...---------------------"
echo "---------------------------------------------------------------------------------------"
echo ""

_distroType=$(sed '$!d' "$CONFIG_FILE")
if [[ "$_distroType" = "arch" ]]; then
	TIMEZONE=$(sed -n '2p' <"$CONFIG_FILE")
	ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
	hwclock --systohc
else
	TIMEZONE=$(sed -n '2p' <"$CONFIG_FILE")
	ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
	install "openntpd-openrc" "pac"
	rc-update add ntpd
	hwclock --systohc
fi
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

if [[ "$_distroType" = "artix" ]]; then
	sudo sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
	sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf
	sudo pacman -Syyy

	sudo pacman -S --noconfirm artix-archlinux-support
	sudo tee -a /etc/pacman.conf <<EOF

[extra]
Include = /etc/pacman.d/mirrorlist-arch

[community]
Include = /etc/pacman.d/mirrorlist-arch
EOF
	sudo pacman-key --populate archlinux
	sudo pacman -Syy
else
	sudo sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
	sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf
	sudo pacman -Syyy
fi

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
	install "nvidia-dkms nvidia-utils nvidia-settings nvidia-prime" "pac"

elif lspci | grep -E "Radeon"; then
	echo "Installing AMD Radeon drivers ..."
	install "xf86-video-amdgpu" "pac"

elif lspci | grep -E "Intel Corporation UHD"; then
	echo "Installing Intel drivers ..."
	install "libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils" "pac"

elif lspci | grep -E "Intel Corporation HD"; then
	echo "Installing Intel drivers ..."
	install "libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils" "pac"

elif lspci | grep -E "Integrated Graphics Controller"; then
	echo "Installing Intel drivers ..."
	install "libva-intel-driver libvdpau-va-gl vulkan-intel libva-intel-driver libva-utils" "pac"
fi

# Essential Packages

echo ""
echo "---------------------------------------------------------------------"
echo "--------------Installing Essential Packages...-----------------------"
echo "---------------------------------------------------------------------"
echo ""

driveType=$(sed -n '4p' <"$CONFIG_FILE")

install "os-prober grub efibootmgr ntfs-3g" "pac"
install "networkmanager network-manager-applet wireless_tools wpa_supplicant net-tools" "pac"
install "dialog mtools dosfstools gptfdisk" "pac"
install "rsync reflector wget" "pac"
install "lsof strace bc" "pac"
install "acpi acpi_call-dkms acpid" "pac"
install "exa bat ripgrep fd bottom sad git-delta tldr duf gping imagemagick" "pac"
install "tokei hyperfine" "pac"

# Configuring GRUB and mkinitcpio

echo ""
echo "---------------------------------------------------------------------"
echo "--------------Configuring GRUB and mkinitcpio...---------------------"
echo "---------------------------------------------------------------------"
echo ""

### Add a flag in GRUB config for encrypted disk

encryptStatus=$(sed -n '11p' <"$CONFIG_FILE")

if [[ "$encryptStatus" = "encrypt" ]]; then
	install "cryptsetup" "pac"
	tee -a /etc/default/grub <<EOF
# Device encryption
GRUB_ENABLE_CRYPTODISK=y
EOF
fi

### Add a flag in GRUB config for enabling logs while booting

rep=$(cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX_DEFAULT" | sed '$ s/.$//' | sed 's/ quiet//' | sed 's/\//\\\//g')
replacewith="${rep}\""
getGrubDefaultArgs=$(cat /etc/default/grub | grep -n "GRUB_CMDLINE_LINUX_DEFAULT")
getLineNumber=$(echo "$getGrubDefaultArgs" | cut -d ":" -f1 | xargs)
sudo sed -i "${getLineNumber}s/.*/${replacewith}/" /etc/default/grub

### Add a flag in GRUB config for setting the resolution of the GRUB menu

rep=$(cat /etc/default/grub | grep "GRUB_GFXMODE=auto" | sed 's/auto/1920x1080/')
getGrubDefaultArgs=$(cat /etc/default/grub | grep -n "GRUB_GFXMODE")
getLineNumber=$(echo "$getGrubDefaultArgs" | cut -d ":" -f1 | xargs)
sudo sed -i "${getLineNumber}s/.*/${rep}/" /etc/default/grub

### Install GRUB

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck
grub-mkconfig -o /boot/grub/grub.cfg

### Add Modules to load btrfs or gpu hooks

FS=$(sed -n '1p' <"$CONFIG_FILE")

if [[ "$FS" = "btrfs" ]]; then

	if lspci | grep -E "NVIDIA|GeForce"; then
		sed -i 's/MODULES=()/MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
		sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1"/' /etc/default/grub
	elif lspci | grep -E "Radeon"; then
		sed -i 's/MODULES=()/MODULES=(btrfs amdgpu)/' /etc/mkinitcpio.conf
	else
		sed -i 's/MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
	fi

	grub-mkconfig -o /boot/grub/grub.cfg
	mkinitcpio -p linux-zen

else

	if lspci | grep -E "NVIDIA|GeForce"; then
		sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
		sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1"/' /etc/default/grub
	elif lspci | grep -E "Radeon"; then
		sed -i 's/MODULES=()/MODULES=(amdgpu)/' /etc/mkinitcpio.conf
	fi

	grub-mkconfig -o /boot/grub/grub.cfg
	mkinitcpio -p linux-zen
fi

### Add more flags in GRUB config for encrypted disk

LUKS_PASSWORD=$(sed -n '12p' <"$CONFIG_FILE")
if [[ "$encryptStatus" = "encrypt" ]]; then

	# Add to mkinitcpio
	getReq=$(cat /etc/mkinitcpio.conf | grep -En "^HOOKS=(.+)$" | head -1 | xargs)
	getLineNumber=$(echo "$getReq" | cut -d":" -f1)
	rep=$(echo $getReq | cut -d":" -f2 | sed 's/keymap //g')
	sed -i "${getLineNumber}s/.*/${rep}/" /etc/mkinitcpio.conf

	getReq=$(cat /etc/mkinitcpio.conf | grep -En "^HOOKS=(.+)$" | head -1 | xargs)
	getLineNumber=$(echo "$getReq" | cut -d":" -f1)
	rep=$(echo $getReq | cut -d":" -f2 | sed 's/keyboard //g')
	sed -i "${getLineNumber}s/.*/${rep}/" /etc/mkinitcpio.conf

	getReq=$(cat /etc/mkinitcpio.conf | grep -En "^HOOKS=(.+)$" | head -1 | xargs)
	getLineNumber=$(echo "$getReq" | cut -d":" -f1)
	rep=$(echo $getReq | cut -d":" -f2 | sed 's/autodetect/autodetect keyboard keymap/g')
	sed -i "${getLineNumber}s/.*/${rep}/" /etc/mkinitcpio.conf

	getReq=$(cat /etc/mkinitcpio.conf | grep -En "^HOOKS=(.+)$" | head -1 | xargs)
	getLineNumber=$(echo "$getReq" | cut -d":" -f1)
	rep=$(echo $getReq | cut -d":" -f2 | sed 's/filesystems/encrypt filesystems/g')
	sed -i "${getLineNumber}s/.*/${rep}/" /etc/mkinitcpio.conf

	DISK=$(sed -n '5p' <"$CONFIG_FILE")
	if [[ ${DISK} =~ "nvme" ]]; then
		UUID_CRYPT_DEVICE=$(blkid | grep "${DISK}p2" | cut -d" " -f2 | xargs)

		# Create a key file

		getReq=$(cat /etc/mkinitcpio.conf | grep -En "^FILES=(.+)$" | head -1 | xargs)
		getLineNumber=$(echo "$getReq" | cut -d":" -f1)
		rep=$(echo "FILES=(\/root\/cryptlvm.keyfile)")
		sed -i "${getLineNumber}s/.*/${rep}/" /etc/mkinitcpio.conf

		dd bs=512 count=4 if=/dev/random of=/root/cryptlvm.keyfile iflag=fullblock
		chmod 000 /root/cryptlvm.keyfile
		echo "${LUKS_PASSWORD}" | cryptsetup -v luksAddKey "${DISK}p2" /root/cryptlvm.keyfile

	else
		UUID_CRYPT_DEVICE=$(blkid | grep "${DISK}2" | cut -d" " -f2 | xargs)

		# Create a key file

		getReq=$(cat /etc/mkinitcpio.conf | grep -En "^FILES=(.+)$" | head -1 | xargs)
		getLineNumber=$(echo "$getReq" | cut -d":" -f1)
		rep=$(echo "FILES=(\/root\/cryptlvm.keyfile)")
		sed -i "${getLineNumber}s/.*/${rep}/" /etc/mkinitcpio.conf

		dd bs=512 count=4 if=/dev/random of=/root/cryptlvm.keyfile iflag=fullblock
		chmod 000 /root/cryptlvm.keyfile
		echo "${LUKS_PASSWORD}" | cryptsetup -v luksAddKey "${DISK}2" /root/cryptlvm.keyfile

	fi

	getGrubDefaultArgs=$(cat /etc/default/grub | grep -n "GRUB_CMDLINE_LINUX_DEFAULT")
	getLineNumber=$(echo "$getGrubDefaultArgs" | cut -d ":" -f1 | xargs)
	getOldArgs=$(echo "$getGrubDefaultArgs" | cut -d ":" -f2 | sed 's/.$//')

	if [[ "$driveType" = "ssd" ]]; then
		cryptstring="cryptdevice=${UUID_CRYPT_DEVICE}:cryptroot:allow-discards root=\/dev\/mapper\/cryptroot cryptkey=rootfs:\/root\/cryptlvm.keyfile"
	else
		cryptstring="cryptdevice=${UUID_CRYPT_DEVICE}:cryptroot root=\/dev\/mapper\/cryptroot cryptkey=rootfs:\/root\/cryptlvm.keyfile"
	fi

	combinedArgsWithcryptstring="${getOldArgs} ${cryptstring}\""
	sed -i "${getLineNumber}s/.*/${combinedArgsWithcryptstring}/" /etc/default/grub

	grub-mkconfig -o /boot/grub/grub.cfg
	mkinitcpio -p linux-zen

fi

# ADD FEATURES TO sudoers

echo ""
echo "-------------------------------------------------------------------------"
echo "--------------Adding insults on wrong password...------------------------"
echo "-------------------------------------------------------------------------"
echo ""

sudo sed -i '71s/.*/Defaults insults/' /etc/sudoers
echo "Done adding insults!"

# THEMING GRUB

echo ""
echo "------------------------------------------------------------------------"
echo "--------------THEMING GRUB...-------------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

### Theme
mkdir archlinux
cd archlinux
wget https://github.com/AdisonCavani/distro-grub-themes/raw/master/themes/arch-linux.tar
tar -xvf ./arch-linux.tar
rm -rf arch-linux.tar
cd ..
sudo mkdir /boot/grub/themes/
sudo cp -r archlinux /boot/grub/themes/
rm -rf archlinux
wget "https://preview.redd.it/th4prtdk6xr61.jpg?width=1080&crop=smart&auto=webp&s=29b79be676887164704fd84859206a866fc78570" -O out.jpg
convert out.jpg background.png
convert ./background.png -brightness-contrast -18% out.png
sudo mv out.png /boot/grub/themes/archlinux/background.png
rm out.jpg background.png
echo 'GRUB_THEME="/boot/grub/themes/archlinux/theme.txt"' | sudo tee -a /etc/default/grub >/dev/null
sudo sed -i 's/#cccccc/#aaff00/g' /boot/grub/themes/archlinux/theme.txt
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Disable wifi powersaver mode

LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC

# Enable Services

echo ""
echo "---------------------------------------------------------"
echo "--------------Enabling Services...-----------------------"
echo "---------------------------------------------------------"
echo ""

if [[ "$_distroType" = "artix" ]]; then
	sudo rc-update add NetworkManager default
	sudo rc-update add acpid default
else
	systemctl enable NetworkManager
	systemctl enable reflector.timer
	systemctl enable acpid
fi

# Fix an issue with Timeshift related to BTRFS

sed -i 's/subvolid.*,//' /etc/fstab

# Regenerate initramfs and update grub

echo ""
echo "--------------------------------------------------------------------------------"
echo "--------------Regenerating initramfs and updating grub...-----------------------"
echo "--------------------------------------------------------------------------------"
echo ""

grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux-zen

# Remove setup files

rm -rf setup
