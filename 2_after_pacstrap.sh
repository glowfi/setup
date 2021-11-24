#!/bin/sh

# SET LOCATION AND SYNCHRONIZE HARDWARE CLOCK

echo ""
echo "---------------------------------------------------------------------------------------"
echo "--------------Setting Location and Synchronizing hardware clock...---------------------"
echo "---------------------------------------------------------------------------------------"
echo ""

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

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
if [[  $TOTALMEM -gt 8000000 ]]; then
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
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

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

echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts
echo "Done setting hostname!"

# SET USER

echo ""
echo "----------------------------------------------------------"
echo "--------------Adding you as user...-----------------------"
echo "----------------------------------------------------------"
echo ""

uname=$1 
fname=$2
upass=$3
rpass=$4

echo root:$4 | chpasswd
useradd -mG wheel $uname
usermod -c "$fname" $uname
echo $uname:$3 | chpasswd
echo "$uname ALL=(ALL) ALL" >> /etc/sudoers.d/$uname
echo "Done adding user!"


# PACAKGES

echo ""
echo "----------------------------------------------------------------"
echo "--------------Installing some packages...-----------------------"
echo "----------------------------------------------------------------"
echo ""

pacman -S --noconfirm grub efibootmgr ntfs-3g networkmanager network-manager-applet wireless_tools wpa_supplicant dialog mtools dosfstools reflector wget rsync || exit 0

# RUST REPLACEMENTS OF SOME GNU COREUTILS (ls cat grep find top)

pacman -S --noconfirm exa bat ripgrep fd bottom || exit 0

# GRUB

echo ""
echo "-------------------------------------------------------"
echo "--------------Installing GRUB...-----------------------"
echo "-------------------------------------------------------"
echo ""

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg


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
