#!/bin/sh

# SYNCHRONIZE

echo -e "-------------------------------------------------------------------------"
echo -e "-----------Setting up mirrors for faster downloads-----------------------"
echo -e "-------------------------------------------------------------------------"

timedatectl set-ntp true
sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
sed -i 's/^#Para/Para/' /etc/pacman.conf
reflector --verbose --protocol https -a 48 -c DE -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Syyy

# PARTITION

echo "--------------------------------------------------"
echo "-------Auto partitioning the disk...--------------"
echo "--------------------------------------------------"

(
  echo n;
  echo ;
  echo ;
  echo +300M;
  echo ef00;
  echo n;
  echo ;
  echo ;
  echo ;
  echo ;
  echo c;
  echo 1;
  echo "EFI";
  echo c;
  echo 2;
  echo "Arch Linux";
  echo w;
  echo Y;
) | gdisk /dev/sda

# FORMAT

echo "-----------------------------------------------------"
echo "--------------Formatting disk...---------------------"
echo "-----------------------------------------------------"


mkfs.fat -F32 /dev/sda1
mkfs.btrfs /dev/sda2


# MOUNT

echo "-----------------------------------------------------"
echo "--------------Mounting disk...-----------------------"
echo "-----------------------------------------------------"


mount /dev/sda2 /mnt
btrfs su cr /mnt/@
umount /mnt


mount -o noatime,compress-force=zstd,space_cache=v2,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot


# BASE SETUP

echo "----------------------------------------------------"
echo "--------------Pacstrapping...-----------------------"
echo "----------------------------------------------------"

pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware amd-ucode btrfs-progs git vim

# GENERATE UUID OF THE DISKS

genfstab -U /mnt >> /mnt/etc/fstab

# GO TO MAIN SYSTEM

arch-chroot /mnt /bin/bash -c "git clone https://github.com/glowfi/setup;chmod +x /setup/2_after_pacstrap.sh;/setup/2_after_pacstrap.sh;rm -rf setup;"
