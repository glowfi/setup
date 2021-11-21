#!/bin/sh

# VIRTUALIZATION SUPPORT

#--INSTALL
# sudo pacman -S dnsmasq virt-manager qemu ebtables edk2-ovmf;sudo usermod -G libvirt -a john;sudo systemctl start libvirtd

#--UNINSTALL
# sudo pacman -Rns dnsmasq virt-manager qemu edk2-ovmf;sudo gpasswd -d john libvirt
