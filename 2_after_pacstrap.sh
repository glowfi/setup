#!/bin/bash

# READ FILES
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE=$SCRIPT_DIR/setup.conf

# SET LOCATION AND SYNCHRONIZE HARDWARE CLOCK

echo ""
echo "---------------------------------------------------------------------------------------"
echo "--------------Setting Location and Synchronizing hardware clock...---------------------"
echo "---------------------------------------------------------------------------------------"
echo ""

TIMEZONE=$(sed -n '2p' <"$CONFIG_FILE")
ln -sf /usr/share/zoneinfo/"$TIMEZONE" /etc/localtime
hwclock --systohc
echo "Done setting location and synchronizing hardware clock!"

# SET KEYMAP

echo ""
echo "---------------------------------------------------------------------------------------"
echo "--------------Setting Keyboard layout...-----------------------------------------------"
echo "---------------------------------------------------------------------------------------"
echo ""

KEYMAP=$(sed -n '3p' <"$CONFIG_FILE")
echo "$KEYMAP" >>/etc/vconsole.conf
echo "Keyboard layout set!"

# OPTIMIZE MAKEPKG

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

# LOCALE GENERATION

echo ""
echo "-----------------------------------------------------"
echo "--------------Setting Locales...---------------------"
echo "-----------------------------------------------------"
echo ""

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >>/etc/locale.conf

# ADD FEATURES TO pacman.conf

echo ""
echo "----------------------------------------------------------------"
echo "--------------Enabling ParallelDownloads...---------------------"
echo "----------------------------------------------------------------"
echo ""

sudo sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf
sudo pacman -Syy

# SET HOSTNAME

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

# SET USER

echo ""
echo "----------------------------------------------------------"
echo "--------------Adding you as user...-----------------------"
echo "----------------------------------------------------------"
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

# DISPLAY DRIVERS

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing display driver...------------------------------"
echo "------------------------------------------------------------------------"
echo ""

## Determine GPU
if lspci | grep -E "NVIDIA|GeForce"; then
	echo "Installing NVIDIA drivers ..."
	pacman -Syyy --noconfirm nvidia-dkms nvidia-utils nvidia-settings
elif lspci | grep -E "Radeon"; then
	echo "Installing AMD Radeon drivers ..."
	pacman -Syyy --noconfirm xf86-video-amdgpu
elif lspci | grep -E "Integrated Graphics Controller"; then
	echo "Installing Intel drivers ..."
	pacman -Syyy --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils
fi

# PACAKGES

echo ""
echo "----------------------------------------------------------------"
echo "--------------Installing some packages...-----------------------"
echo "----------------------------------------------------------------"
echo ""

driveType=$(sed -n '4p' <"$CONFIG_FILE")
if [[ "$driveType" = "ssd" ]]; then
	pacman -Syyy --noconfirm os-prober grub efibootmgr ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools reflector wget rsync strace acpi acpi_call-dkms acpid || exit 0
elif [[ "$driveType" = "non-ssd" ]]; then
	pacman -Syyy --noconfirm grub efibootmgr ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools reflector wget rsync strace acpi acpi_call-dkms acpid || exit 0
fi

# RUST REPLACEMENTS OF SOME GNU COREUTILS (ls cat grep find top)

pacman -Syyy --noconfirm exa bat ripgrep fd bottom hyperfine sad diff-so-fancy tokei || exit 0

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

# UPDATING mkinitcpio.conf

if lspci | grep -E "Radeon"; then
	sed -i 's/MODULES=()/MODULES=(btrfs amdgpu)/' /etc/mkinitcpio.conf
	mkinitcpio -p linux-zen
else
	sed -i 's/MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
	mkinitcpio -p linux-zen
fi

# ENABLE PACKAGES

echo ""
echo "---------------------------------------------------------"
echo "--------------Enabling Services...-----------------------"
echo "---------------------------------------------------------"
echo ""

systemctl enable NetworkManager
systemctl enable reflector.timer
systemctl enable acpid

# REMOVE SCRIPT DIRECTORY

rm -rf setup
