#!/bin/bash

# READ FILES
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE=$SCRIPT_DIR/setup.conf

# Read Username
USERNAME=$(sed -n '6p' <"$CONFIG_FILE")


# SET LOCATION AND SYNCHRONIZE HARDWARE CLOCK

echo ""
echo "---------------------------------------------------------------------------------------"
echo "--------------Setting Location and Synchronizing hardware clock...---------------------"
echo "---------------------------------------------------------------------------------------"
echo ""

LOCATION=$(sed -n '2p' <"$CONFIG_FILE")
ln -sf /usr/share/zoneinfo/"$LOCATION"/etc/localtime
hwclock --systohc
echo "Done setting location and synchronizing hardware clock!"

# Set keymaps
KEYMAP=$(sed -n '3p' <"$CONFIG_FILE")
localectl --no-ask-password set-keymap ${KEYMAP}

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

sed -i '177s/.//' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >>/etc/locale.conf

# ADD FEATURES TO pacman.conf

echo ""
echo "----------------------------------------------------------------"
echo "--------------Enabling ParallelDownloads...---------------------"
echo "----------------------------------------------------------------"
echo ""

sudo sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
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
echo "127.0.1.1 arch.localdomain $hostname" >>/etc/hosts
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
	sudo pacman -S --noconfirm nvidia-dkms nvidia-utils nvidia-settings
elif lspci | grep -E "Radeon"; then
    echo "Installing AMD Radeon drivers ..."
	sudo pacman -S --noconfirm xf86-video-amdgpu
elif lspci | grep -E "Integrated Graphics Controller"; then
    echo "Installing Intel drivers ..."
	sudo pacman -S --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils
fi

# PACAKGES

echo ""
echo "----------------------------------------------------------------"
echo "--------------Installing some packages...-----------------------"
echo "----------------------------------------------------------------"
echo ""

driveType=$(sed -n '4p' <"$CONFIG_FILE")
if [[ "$driveType" = "ssd" ]]; then
    pacman -S --noconfirm os-prober grub efibootmgr ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools reflector wget rsync || exit 0
elif [[ "$driveType" = "non-ssd" ]]; then
    pacman -S --noconfirm grub efibootmgr ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools reflector wget rsync || exit 0    
fi

# RUST REPLACEMENTS OF SOME GNU COREUTILS (ls cat grep find top)

pacman -S --noconfirm exa bat ripgrep fd bottom || exit 0

# GRUB

echo ""
echo "-------------------------------------------------------"
echo "--------------Installing GRUB...-----------------------"
echo "-------------------------------------------------------"
echo ""

if [[ "$driveType" = "ssd" ]]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch
    grub-mkconfig -o /boot/grub/grub.cfg
elif [[ "$driveType" = "non-ssd" ]]; then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
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

# COPY 
cp -R /setup /home/$USERNAME/
