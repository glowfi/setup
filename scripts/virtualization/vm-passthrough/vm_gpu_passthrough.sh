#!/usr/bin/env bash

########## Sources ##########

# https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF#Using_identical_guest_and_host_GPUs
# https://forum.manjaro.org/t/virt-manager-fails-to-detect-ovmf-uefi-firmware/110072

########## Backup GRUB,mkinitcpio ##########

mkdir Backup
cp /etc/default/grub Backup
cp /etc/mkinitcpio.conf Backup

########## Detecting CPU and making IOMMU string ##########

# Detect CPU
proc_type=$(lscpu | awk '/Vendor ID:/ {print $3}')
if [[ ${proc_type} =~ "GenuineIntel" ]]; then
	IOMMU="intel_iommu=on rd.driver.pre=vfio-pci kvm.ignore_msrs=1"
	echo "Set Intel IOMMU On"
elif [[ ${proc_type} =~ "AuthenticAMD" ]]; then
	IOMMU="amd_iommu=on rd.driver.pre=vfio-pci kvm.ignore_msrs=1"
	echo "Set AMD IOMMU On"
fi

# Combining IOMMU string with current GRUB_CMDLINE_LINUX_DEFAULT
getGrubDefaultArgs=$(cat /etc/default/grub | grep -n "GRUB_CMDLINE_LINUX_DEFAULT")
getLineNumber=$(echo "$getGrubDefaultArgs" | cut -d ":" -f1 | xargs)
getOldArgs=$(echo "$getGrubDefaultArgs" | cut -d ":" -f2 | sed 's/.$//')
combinedArgsWithIOMMU="${getOldArgs} ${IOMMU}\""

########## Grub ##########

# Copy a the current grub setting
cp /etc/default/grub new_grub
sed -i "${getLineNumber}s/.*/${combinedArgsWithIOMMU}/" new_grub

# Copy Updated GRUB
cp new_grub /etc/default/grub

########## mkinitcpio ##########

MODULES='vfio_pci vfio vfio_iommu_type1 vfio_virqfd'
FILES='/usr/bin/vfio-pci-override.sh'
HOOKS='vfio'
cp /etc/mkinitcpio.conf new_mkinitcpio

# Add the require modules to load at startup [Keeps ur old parameter intact and adds new parameters over existing]
sed -i "\|^MODULES=| s|(\(.*\))|(${MODULES} \1)|" new_mkinitcpio
sed -i "\|^MODULES=| s|\"\(.*\)\"|\"${MODULES} \1\"|" new_mkinitcpio

# Add the vfio-pci-override script in the files [Keeps ur old parameter intact and adds new parameters over existing]
sed -i "\|^FILES=| s|(\(.*\))|(${FILES} \1)|" new_mkinitcpio
sed -i "\|^FILES=| s|\"\(.*\)\"|\"${FILES} \1\"|" new_mkinitcpio

# Add vfio-pci-override script as a hook to trigger automatically during system startup [Keeps ur old parameter intact and adds new parameters over existing]
sed -i "\|^HOOKS=| s|base\(.*\) udev|base ${HOOKS}\1 udev|" new_mkinitcpio

# Copy Updated mkinitcpio
cp new_mkinitcpio /etc/mkinitcpio.conf

########## Regenerate GRUB,mkinitcpio ##########

grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux-zen

########## Copy necessary files ##########

# Main file containg logic to assign Primary Used GPU as the passthough device
cp vfio-pci-override.sh /usr/bin/vfio-pci-override.sh
chmod +x /usr/bin/vfio-pci-override.sh

# Configuration file to load gpu as vfio module
cp vfio.conf /etc/modprobe.d/

# Automatically override vfio-pci settings
cp vfio-install /etc/initcpio/install/vfio
cp vfio-hooks /etc/initcpio/hooks/vfio

########## Allow libvirt to autostart ##########

systemctl enable libvirtd.service

########## Checking for TPM ##########

# ls /dev/tpm* 2>/dev/null 1>/dev/null

# if [ $? = 0 ]; then
# 	echo "TPM found. It is not necessary to install a TPM emulator."

# else
# 	echo " "
# 	echo " "
# 	echo "TPM is required for running Windows 11 VMs!"
# 	echo "Do you want to install a TPM emulator 'swtpm'? y/n  "
# 	read TPM
# 	if [ $TPM = y ]; then
# 		pacman -S --noconfirm swtpm

# 	fi
# fi
