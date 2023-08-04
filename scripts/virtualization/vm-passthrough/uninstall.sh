#!/bin/bash

### Restore Backup

if [ -a Backup/grub ]; then
	rm /etc/default/grub
	cp Backup/grub /etc/default/
fi

if [ -a Backup/mkinitcpio.conf ]; then
	rm /etc/mkinitcpio.conf
	cp Backup/mkinitcpio.conf /etc/
fi

### Remove necessary files

rm /usr/bin/vfio-pci-override.sh

rm /etc/initcpio/install/vfio

rm /etc/initcpio/hooks/vfio

rm /etc/modprobe.d/vfio.conf

rm -rf Backup new_grub new_mkinitcpio

### Stop Libvirtd Service

systemctl disable libvirtd
systemctl stop libvirtd

### Regenerate GRUB,mkinitcpio

grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux-zen
