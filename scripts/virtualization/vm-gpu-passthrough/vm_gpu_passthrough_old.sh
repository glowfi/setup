#!/bin/bash

if [[ -f "$HOME/.config/gpupass" ]]; then

	# If file exist means we have already passthroughed our GPU
	rm $HOME/.config/gpupass

	## EDIT GRUB
	sudo sed -i '6s/.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 lsm=landlock,lockdown,yama,apparmor,bpf"/' /etc/default/grub
	sudo sed -i '6a\GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1"' /etc/default/grub
	sudo grub-mkconfig -o /boot/grub/grub.cfg

	## DELETE vfio.conf
	sudo rm -rf /etc/modprobe.d/vfio.conf

	## ADD BACK NVIDIA MODULES
	sudo sed -i 's/MODULES=(btrfs)/MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

	## Regenerate initramfs
	sudo mkinitcpio -p linux-zen

	## Show message to remove flags
	clear
	echo "Remove the flags from startup script !"

else

	# If file does not exist it means we are yet to passthrough our GPU
	touch $HOME/.config/gpupass

	## EDIT GRUB
	sudo sed -i '6s/.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 lsm=landlock,lockdown,yama,apparmor,bpf amd_iommu=on vfio-pci.ids=10de:25a2,10de:2291"/' /etc/default/grub
	sudo sed -i '7d' /etc/default/grub

	sudo grub-mkconfig -o /boot/grub/grub.cfg

	## EDIT vfio.conf
	sudo -E nvim -c ":q" /etc/modprobe.d/vfio.conf
	sudo echo | sudo tee /etc/modprobe.d/vfio.conf >/dev/null
	sudo echo "options vfio-pci ids=10de:25a2,10de:2291" | sudo tee -a /etc/modprobe.d/vfio.conf >/dev/null
	sudo echo "softdep nvidia pre: vfio-pci" | sudo tee -a /etc/modprobe.d/vfio.conf >/dev/null
	sudo sed -i "1d" /etc/modprobe.d/vfio.conf

	## GET RID OF ANY NVIDIA MODULES
	sudo sed -i 's/MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)/MODULES=(btrfs)/' /etc/mkinitcpio.conf

	## Regenerate initramfs
	sudo mkinitcpio -p linux-zen

	## Show message to add flags
	clear
	echo "Add the below flags to your start script ...."
	echo -e "\e[31m-device vfio-pci,host=01:00.0,multifunction=on \\
-device vfio-pci,host=01:00.1 \\ \e[0m"

fi
