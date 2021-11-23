#!/bin/sh

# SELECT DISK TO FORMAT

echo ""
echo "-------------------------------------------------"
echo "-------Select your disk to format----------------"
echo "-------------------------------------------------"
echo ""
lsblk
echo ""
echo "Please enter disk to work on: (example /dev/sda)"
read DISK
echo ""
echo "THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK"
read -p "are you sure you want to continue (Y/N):" formatdisk


# PACSTRAP BASE SYSTEM

case $formatdisk in
    y|Y|yes|Yes|YES)

    # ACCEPT USERNAME AND FULLNAME

    echo ""
    echo "What would be the username?"
    read uname
    echo "What would be the fullname of the user?"
    read fname
   
   # SYNCHRONIZE

    echo ""
    echo -e "-------------------------------------------------------------------------"
    echo -e "-----------Setting up mirrors for faster downloads-----------------------"
    echo -e "-------------------------------------------------------------------------"
    echo ""

    timedatectl set-ntp true
    sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
    sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
    reflector --verbose --protocol https -a 48 -c DE -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
    pacman -Syyy

    # ALIGN DISK 

    echo ""
    echo "--------------------------------------------------"
    echo "-------Aligning new GPT partition...--------------"
    echo "--------------------------------------------------"
    echo ""

    sgdisk -Z ${DISK} 
    sgdisk -a 2048 -o ${DISK} 

    # PARTITION

    echo ""
    echo "--------------------------------------------------"
    echo "-------Auto partitioning the disk...--------------"
    echo "--------------------------------------------------"
    echo ""

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
    ) | gdisk ${DISK}

    # FORMAT

    echo ""
    echo "-----------------------------------------------------"
    echo "--------------Formatting disk...---------------------"
    echo "-----------------------------------------------------"
    echo ""

    if [[ ${DISK} =~ "nvme" ]]; then
    mkfs.fat -F32 "${DISK}p1"
    mkfs.btrfs "${DISK}p2"
    else
    mkfs.fat -F32 "${DISK}1"
    mkfs.btrfs "${DISK}2"
    fi


    # MOUNT

    echo ""
    echo "-----------------------------------------------------"
    echo "--------------Mounting disk...-----------------------"
    echo "-----------------------------------------------------"
    echo ""

    if [[ ${DISK} =~ "nvme" ]]; then
    mount "${DISK}p2" /mnt
    btrfs su cr /mnt/@
    umount /mnt
    
    mount -o noatime,compress-force=zstd,space_cache=v2,subvol=@ "${DISK}p2" /mnt
    mkdir -p /mnt/boot
    mount "${DISK}p1" /mnt/boot
    else
    mount "${DISK}2" /mnt
    btrfs su cr /mnt/@
    umount /mnt
    
    mount -o noatime,compress-force=zstd,space_cache=v2,subvol=@ "${DISK}2" /mnt
    mkdir -p /mnt/boot
    mount "${DISK}1" /mnt/boot
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
            pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware intel-ucode btrfs-progs git vim
    elif [[ ${proc_type} =~ "AuthenticAMD" ]]; then
            echo ""
            echo "Installing AMD microcode ..."
            echo ""
            pacstrap /mnt base base-devel linux-zen linux-zen-headers linux-firmware amd-ucode btrfs-progs git vim
    fi

    # GENERATE UUID OF THE DISKS

    genfstab -U /mnt >> /mnt/etc/fstab

    # GO TO MAIN SYSTEM

    arch-chroot /mnt /bin/bash -c "git clone https://github.com/glowfi/setup;chmod +x /setup/2_after_pacstrap.sh;/setup/2_after_pacstrap.sh $uname \"$fname\";rm -rf setup;"
    umount -a 
    reboot
    ;;

    n|N|no|No|NO)
        echo ""
        printf '\e[1;31m%-6s\e[m' "Installation Cancelled!"
        echo ""
    ;;

esac
