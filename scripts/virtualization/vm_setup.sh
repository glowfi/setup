#!/usr/bin/env bash

#### Constant Variables
unattendedUpdateScripts="no"
reconfigure="no"
isWindows="no"
name=""
cores="4"
threads="2"
ram="4G"
vga="virtio"
diskSize="30G"
gpu=""
VMS_PATH="$HOME/Downloads/VMS"
VMS_ISO="$HOME/Downloads/VMS_ISO"
CONFIG_FILE=".config"

while [[ $# > 0 ]]; do
	case "$1" in

	-ups | --unattendedUpdateScripts)
		unattendedUpdateScripts="$2"
		shift
		;;
	-reconf | --reconfigure)
		reconfigure="$2"
		shift
		;;
	-iswin | --isWindows)
		isWindows="$2"
		shift
		;;
	-n | --name)
		name="$2"
		shift
		;;
	-c | --cores)
		cores="$2"
		shift
		;;
	-t | --threads)
		threads="$2"
		shift
		;;
	-r | --ram)
		ram="$2"
		shift
		;;
	-v | --vga)
		vga="$2"
		shift
		;;
	-ds | --diskSize)
		diskSize="$2"
		shift
		;;
	-vmp | --vmpath)
		VMS_PATH="$2"
		shift
		;;
	-g | --goto)
		goto="$2"
		shift
		;;

	--help | *)
		echo "This is a tool to setup a VM using QEMU+KVM"
		exit 1
		;;
	esac
	shift
done

getGPUlist() {

	#Initializing the list of all IOMMU groups
	GROUP=$(find /sys/kernel/iommu_groups/ -type l | cut -d '/' -f 5,7 --output-delimiter='-')

	for i in $GROUP; do

		#K holds the group number
		k=$(echo $i | cut -d '-' -f 1)

		#L holds the address
		l=$(echo $i | cut -d '-' -f 2)

		#J holds the part of the address that's pasted into lspci to get the name
		j=$(echo $i | cut -d ':' -f 2,3,4)

		#M holds the kernel driver in use
		m=$(lspci -k -s $j | grep "Kernel driver in use")

		echo -n "Group: "

		#This if-statement is here for proper alignment. If group is less than 10, a space is added.
		if [ $k -lt 10 ]; then
			echo -n " $k  "
		else
			echo -n " $k "
		fi

		#Outputting the address
		echo -n " $l "

		#Outputting the name and id
		echo -n "$(lspci -nn | grep $j | cut -d ' ' -f 2-)"

		#Only displays "   Driver:" if m is not an empty string
		if ! [ -z "$m" ]; then
			echo -n "   Driver:"
		fi

		#Outputting the kernel driver in use
		echo "$m" | cut -d ':' -f 2

		#The output is sorted numerically based on the second space-separated field.
	done | sort -nk2

}

addScripts() {

	### Copy OVMF_VARS
	cp -r /usr/share/edk2-ovmf/x64/OVMF_VARS.fd .

	### Start Script

	touch start.sh
	touch start_secboot.sh

	### Check vga type

	if [[ "$vga" == "qxl" ]]; then
		videoSettings="-vga qxl \\"
		spiceSettings="-spice unix=on,addr=/run/user/1000/spice.sock,disable-ticketing=on,image-compression=off,gl=off,seamless-migration=on \\"
	elif [[ "$vga" == "virtio" ]]; then
		### Check GPU
		if [[ "$gpu" = "Software" || "$gpu" = "" ]]; then
			videoSettings="-device virtio-vga \\"
			spiceSettings="-spice unix=on,addr=/run/user/1000/spice.sock,disable-ticketing=on,image-compression=off,gl=off,seamless-migration=on \\"
		else
			videoSettings="-device virtio-vga-gl \\"
			spiceSettings="-spice unix=on,addr=/run/user/1000/spice.sock,disable-ticketing=on,image-compression=off,gl=on,rendernode=/dev/dri/by-path/pci-${gpu}-render,seamless-migration=on \\"
		fi
	fi

	### Handle isos and shared folder

	if [[ "$isWindows" == "yes" || "$isWindows" == "y" ]]; then

		echo -e "\nAre you trying to install Windows 7? [yes/y/no/No] (No default) :"
		read isWindows7

		if [[ "$isWindows7" == "yes" || "$isWindows7" == "y" ]]; then
			_iso_sharedfolder_string="-drive file=${name}.iso,media=cdrom \\
-drive file=fat:rw:${VMS_PATH}/${name}/sharedFolder,format=raw &
		"
		else
			### Copy virtio
			cp -r "${VMS_ISO}/virtio.iso" "${VMS_PATH}/${name}"

			_iso_sharedfolder_string="-drive file=${name}.iso,media=cdrom \\
		-drive file=virtio.iso,media=cdrom \\
-drive file=fat:rw:${VMS_PATH}/${name}/sharedFolder,format=raw &
		"
		fi

	else
		_iso_sharedfolder_string="-drive media=cdrom,file=${name}.iso \\
		-drive file=fat:rw:${VMS_PATH}/${name}/sharedFolder,format=raw &"
	fi

	### Startup script [UEFI+Secure Boot Disabled]

	echo "#!/usr/bin/env bash

# Kill all sockets
rm -rf "${name}-agent.sock"

# Kill any running python script qemu with process name as the current os name
ps aux | grep \"qemu\"| grep \"${name}\" |head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"

# Startup script
qemu-system-x86_64 \\
    -name "${name}",process=${name} \\
	-enable-kvm -machine q35,smm=on,vmport=off,hpet=off,acpi=on -cpu host,kvm=on,migratable=on,topoext \\
    -overcommit mem-lock=off -smp cores=${cores},threads=${threads},sockets=1 -m ${ram} -device virtio-balloon \\
    ${videoSettings}
    -display none \\
	${spiceSettings}
    -audiodev spice,id=audio0 \\
    -device intel-hda \\
    -device hda-duplex,audiodev=audio0 \\
    -no-user-config \\
    -rtc base=localtime,clock=host,driftfix=slew \\
	-global kvm-pit.lost_tick_policy=delay \\
	-boot strict=on \\
    -device virtio-serial-pci \\
    -chardev socket,id=agent0,path="${name}-agent.sock",server=on,wait=off \\
	-device virtserialport,chardev=agent0,name=org.qemu.guest_agent.0 \\
	-chardev spicevmc,id=vdagent0,name=vdagent \\
	-device virtserialport,chardev=vdagent0,name=com.redhat.spice.0 \\
	-chardev spiceport,id=webdav0,name=org.spice-space.webdav.0 \\
	-device virtserialport,chardev=webdav0,name=org.spice-space.webdav.0 \\
	-device ich9-usb-ehci1,id=usb \\
	-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on \\
	-device ich9-usb-uhci2,masterbus=usb.0,firstport=2 \\
	-device ich9-usb-uhci3,masterbus=usb.0,firstport=4 \\
	-chardev spicevmc,name=usbredir,id=usbredirchardev1 \\
	-device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \\
	-chardev spicevmc,name=usbredir,id=usbredirchardev2 \\
	-device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \\
	-chardev spicevmc,name=usbredir,id=usbredirchardev3 \\
	-device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \\
	-k en-us \\
	-device usb-ehci,id=input \\
	-device usb-kbd,bus=input.0 \\
	-device usb-mouse,bus=input.0 \\
    -global driver=cfi.pflash01,property=secure,value=on -drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \\
    -drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \\
	-drive file=Image.img \\
	-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \\
    ${_iso_sharedfolder_string}


        # Open remote viewer
        remote-viewer spice+unix:///run/user/1000/spice.sock &" >>start.sh

	chmod +x start.sh

	### Startup script [UEFI+Secure Boot Enabled]

	echo "#!/usr/bin/env bash

# Kill all sockets
rm -rf "${name}-agent.sock"

# Kill any running python script qemu with process name as the current os name
ps aux | grep \"qemu\"| grep \"${name}\" |head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"

# Startup script
qemu-system-x86_64 \\
    -name "${name}",process=${name} \\
	-enable-kvm -machine q35,smm=on,vmport=off,hpet=off,acpi=on -cpu host,kvm=on,migratable=on,topoext \\
    -overcommit mem-lock=off -smp cores=${cores},threads=${threads},sockets=1 -m ${ram} -device virtio-balloon \\
    ${videoSettings}
    -display none \\
	${spiceSettings}
    -audiodev spice,id=audio0 \\
    -device intel-hda \\
    -device hda-duplex,audiodev=audio0 \\
    -no-user-config \\
    -rtc base=localtime,clock=host,driftfix=slew \\
	-global kvm-pit.lost_tick_policy=delay \\
	-boot strict=on \\
    -device virtio-serial-pci \\
    -chardev socket,id=agent0,path="${name}-agent.sock",server=on,wait=off \\
	-device virtserialport,chardev=agent0,name=org.qemu.guest_agent.0 \\
	-chardev spicevmc,id=vdagent0,name=vdagent \\
	-device virtserialport,chardev=vdagent0,name=com.redhat.spice.0 \\
	-chardev spiceport,id=webdav0,name=org.spice-space.webdav.0 \\
	-device virtserialport,chardev=webdav0,name=org.spice-space.webdav.0 \\
	-device ich9-usb-ehci1,id=usb \\
	-device ich9-usb-uhci1,masterbus=usb.0,firstport=0,multifunction=on \\
	-device ich9-usb-uhci2,masterbus=usb.0,firstport=2 \\
	-device ich9-usb-uhci3,masterbus=usb.0,firstport=4 \\
	-chardev spicevmc,name=usbredir,id=usbredirchardev1 \\
	-device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \\
	-chardev spicevmc,name=usbredir,id=usbredirchardev2 \\
	-device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \\
	-chardev spicevmc,name=usbredir,id=usbredirchardev3 \\
	-device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \\
	-k en-us \\
	-device usb-ehci,id=input \\
	-device usb-kbd,bus=input.0 \\
	-device usb-mouse,bus=input.0 \\
    -global driver=cfi.pflash01,property=secure,value=on -drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.secboot.fd,readonly=on \\
    -drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \\
	-drive file=Image.img \\
	-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \\
    ${_iso_sharedfolder_string}


        # Open remote viewer
        remote-viewer spice+unix:///run/user/1000/spice.sock &" >>start_secboot.sh

	chmod +x start_secboot.sh

	### Cleanup Script

	touch clean.sh

	echo "#!/usr/bin/env bash

# Kill all sockets
rm -rf "${name}-agent.sock"

# Kill any running python script qemu with the vm name
ps aux | grep \"qemu\"| grep \"${name}\" |head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"" >>clean.sh

	chmod +x clean.sh

	#### Include a minimal start Script [Minimal UEFI+Secure Boot Disabled]

	touch fallback-start.sh
	echo "#!/usr/bin/env bash
qemu-system-x86_64 -enable-kvm \\
	-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \\
	-machine q35,accel=kvm,smm=on \\
	-cpu host \\
	-device ich9-intel-hda,id=sound0,bus=pcie.0,addr=0x1b -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0 \\
    -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 \\
	-boot menu=on \\
	-global driver=cfi.pflash01,property=secure,value=on \\
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \\
	-drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \\
	-drive file=Image.img \\
	-m ${ram} \\
	-smp ${cores} \\
	-vga ${vga} \\
	-display sdl,gl=on \\
	-cdrom ${name}.iso &" >>fallback-start.sh
	chmod +x fallback-start.sh

	#### Include a minimal start Script [Legacy BIOS]

	touch fallback-start-BIOS.sh
	echo "#!/usr/bin/env bash
qemu-system-x86_64 -enable-kvm \\
	-machine q35,accel=kvm,smm=on \\
	-cpu host \\
	-device ich9-intel-hda,id=sound0,bus=pcie.0,addr=0x1b -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0 \\
    -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 \\
	-boot menu=on \\
	-drive file=Image.img \\
	-m ${ram} \\
	-smp ${cores} \\
	-vga ${vga} \\
	-display sdl,gl=on \\
	-cdrom ${name}.iso &" >>fallback-start-BIOS.sh
	chmod +x fallback-start-BIOS.sh

	#### Save the current configuration

	rm -rf "${CONFIG_FILE}"
	touch "${CONFIG_FILE}"
	echo "${name}" >>"${CONFIG_FILE}"
	echo "${threads}" >>"${CONFIG_FILE}"
	echo "${ram}" >>"${CONFIG_FILE}"
	echo "${cores}" >>"${CONFIG_FILE}"
	echo "${vga}" >>"${CONFIG_FILE}"
	echo "${gpu}" >>"${CONFIG_FILE}"
	echo "${isWindows}" >>"${CONFIG_FILE}"
}

takeInput() {
	echo "Enter cores to use: (Default 4)"
	read _cores

	echo "Enter threads to use: (Default 2)"
	read _threads

	echo "Enter ram to use: (Default 4G)"
	read _ram

	if [[ "$1" == "reconf" ]]; then
		echo "By how much the disk size to be increased : [Enter something sensisble like 100G(in gigabytes),100M(in megabytes),100K(in kilobytes)]"
		read _diskSize
		if [[ "_diskSize" != "" ]]; then
			qemu-img resize ./Image.img "+${_diskSize}"
		fi
	else
		echo "Enter Disk Size to use: (Default 30G) [Enter something sensisble like 100G(in gigabytes),100M(in megabytes),100K(in kilobytes)]"
		read _diskSize

	fi

	echo "Enter video drivers to use: (Default virtio) [virtio/qxl]"
	read _vga

	if [[ "$_vga" != "virtio" && "$_vga" != "" ]]; then
		_gpu="Software"
	else
		echo "Please be patient. This may take a couple seconds to detect GPU."
		gpuList=$(getGPUlist | grep "VGA compatible controller")
		gpuList=$(echo -e "$gpuList\nUse basic Software rendering")
		_gpu=$(echo "$gpuList" | fzf --prompt "Select GPU to use : [Safe options: AMD/Intel/Basic Software rendering] :" | awk -F" " '{print $3}' | xargs)
	fi

	if [[ "$_cores" != "" ]]; then
		cores="$_cores"
	fi

	if [[ "$_threads" != "" ]]; then
		threads="$_threads"
	fi

	if [[ "$_ram" != "" ]]; then
		ram="$_ram"
	fi

	if [[ "$_diskSize" != "" ]]; then
		diskSize="$_diskSize"
	fi

	if [[ "$_vga" != "" ]]; then
		vga="$_vga"
	fi

	if [[ "$_gpu" != "" ]]; then
		gpu="$_gpu"
	fi

}

takeCliArguments() {
	echo "Are you trying to install windows?: [yes,y/no,n]"
	read _isWindows

	if [[ "$_isWindows" != "" ]]; then
		if [[ "$_isWindows" == "no" || "$_isWindows" == "n" || "$_isWindows" == "yes" || "$_isWindows" == "y" ]]; then
			isWindows="$_isWindows"
		else
			echo "Please Enter Properly if you are trying to install Windows or not!"
			exit 1
		fi
	fi

	# Get ISO Location
	THEME=$(echo "ansi") # gruvbox-dark
	isoLocation=$(fd --type f . $HOME | fzf --prompt "Choose ISO Location:" --reverse --preview "bat --theme $THEME --style numbers,changes --color=always {}" | xargs -I {} realpath "{}")

	# Get Confirmation
	echo -e "Are you sure to go with this ==> \e[31m${isoLocation}\e[0m \e[33m[y,yes/n,no]\e[0m"
	read _confirm

	if [[ "$_confirm" = "no" || "$_confirm" = "n" ]]; then
		echo "Exited!"
	elif [[ "$_confirm" = "yes" || "$_confirm" = "y" ]]; then
		if [[ "$isoLocation" != "" ]]; then

			echo "Enter the name of the virtual machine: [Do not give spaces while naming]"
			read _name

			# Take Input
			takeInput

			name=$(echo "$_name" | tr " " "-")

			# Create Directory if not exits
			mkdir -p "${VMS_PATH}"

			# Go to VMS Directory
			cd "${VMS_PATH}"

			# Create a Directory with the given name
			mkdir "${name}"
			cd "${name}"

			# Create a shared folder
			mkdir -p sharedFolder
			chmod 777 sharedFolder

			# Copy the iso
			isoname=$(echo "${isoLocation}" | awk -F"/" '{print $NF}')
			cp -r "${isoLocation}" .
			mv "${isoname}" "${name}.iso"

			# Create QCOW
			qemu-img create -f qcow2 Image.img "${diskSize}"

			# Add Scripts
			addScripts

			cd ..
		fi
	else
		echo "Please type either yes or no!"
	fi
}

if [[ "$unattendedUpdateScripts" = "yes" ]]; then
	cd "${goto}"
	name=$(sed -n '1p' <"$CONFIG_FILE")
	threads=$(sed -n '2p' <"$CONFIG_FILE")
	ram=$(sed -n '3p' <"$CONFIG_FILE")
	cores=$(sed -n '4p' <"$CONFIG_FILE")
	vga=$(sed -n '5p' <"$CONFIG_FILE")
	gpu=$(sed -n '6p' <"$CONFIG_FILE")
	isWindows=$(sed -n '7p' <"$CONFIG_FILE")

	find . -maxdepth 1 ! -name '*.iso' ! -name '*.img' ! -type d -delete
	addScripts

else
	if [[ "$reconfigure" == "no" ]]; then
		takeCliArguments
	else
		cd "${goto}"
		takeInput "reconf"
		configPath="${goto}/${CONFIG_FILE}"
		isWindows=$(sed -n '7p' <"$configPath")
		find . -maxdepth 1 ! -name '*.iso' ! -name '*.img' ! -type d -delete
		addScripts
	fi

fi
