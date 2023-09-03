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

addScripts() {

	### Copy OVMF_VARS
	cp -r /usr/share/edk2-ovmf/x64/OVMF_VARS.fd .

	### Start Script

	touch start.sh

	if [[ "$isWindows" == "yes" || "$isWindows" == "y" ]]; then

		### Copy virtio
		cp -r "${VMS_ISO}/virtio.iso" "${VMS_PATH}/${name}"

		echo "#!/usr/bin/env bash

# Kill all sockets
rm -rf "${name}-monitor.socket"
rm -rf "${name}-serial.socket"
rm -rf "${name}-agent.sock"
rm -rf "${name}.socket"

# Kill any running python script qemu spicy
ps aux | grep \"qemu\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"
ps aux | grep \"spicy\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"

qemu-system-x86_64 \\
    -name "${name}",process=${name} \\
    -enable-kvm -machine q35,smm=off,vmport=off -cpu host,kvm=on,topoext \\
    -smp cores=${cores},threads=${threads},sockets=1 -m ${ram} -device virtio-balloon \\
    -vga ${vga} \\
    -display none \\
    -audiodev spice,id=audio0 \\
    -device intel-hda \\
    -device hda-duplex,audiodev=audio0 \\
    -rtc base=localtime,clock=host,driftfix=slew \\
    -spice disable-ticketing=on,port=5930,addr=127.0.0.1 \\
    -device virtio-serial-pci \\
    -chardev socket,id=agent0,path="${name}-agent.sock",server=on,wait=off \\
    -device virtserialport,chardev=agent0,name=org.qemu.guest_agent.0 \\
    -chardev spicevmc,id=vdagent0,name=vdagent \\
    -device virtserialport,chardev=vdagent0,name=com.redhat.spice.0 \\
    -chardev spiceport,id=webdav0,name=org.spice-space.webdav.0 \\
    -device virtserialport,chardev=webdav0,name=org.spice-space.webdav.0 \\
    -device virtio-rng-pci,rng=rng0 \\
    -object rng-random,id=rng0,filename=/dev/urandom \\
    -device qemu-xhci,id=spicepass -chardev spicevmc,id=usbredirchardev1,name=usbredir \\
    -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \\
    -chardev spicevmc,id=usbredirchardev2,name=usbredir \\
    -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \\
    -chardev spicevmc,id=usbredirchardev3,name=usbredir \\
    -device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \\
    -device pci-ohci,id=smartpass -device usb-ccid \\
    -chardev spicevmc,id=ccid,name=smartcard \\
    -device ccid-card-passthru,chardev=ccid \\
    -device usb-ehci,id=input \\
    -device usb-kbd,bus=input.0 \\
    -k en-us \\
    -device usb-mouse,bus=input.0 \\
    -global driver=cfi.pflash01,property=secure,value=on -drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \\
    -drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \\
	-drive file=Image.img \\
    -fsdev local,id=fsdev0,path=/home/$USER/Public,security_model=mapped-xattr \\
    -device virtio-9p-pci,fsdev=fsdev0,mount_tag=Public-$USER \\
    -monitor unix:"${name}-monitor.socket",server,nowait \\
    -serial unix:"${name}-serial.socket",server,nowait \\
    -drive file=${name}.iso,media=cdrom \\
    -drive file=virtio.iso,media=cdrom \\
    -drive file=fat:rw:${VMS_PATH}/${name}/sharedFolder,format=raw &


# Open Spice Window
        setsid spicy -p 5930 --title="${name}" &" >>start.sh

		chmod +x start.sh

		### Cleanup Script

		touch clean.sh

		echo "#!/usr/bin/env bash

# Kill all sockets
rm -rf "${name}-monitor.socket"
rm -rf "${name}-serial.socket"
rm -rf "${name}-agent.sock"
rm -rf "${name}.socket"

# Kill any running python script qemu spicy
ps aux | grep \"qemu\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"
        ps aux | grep \"spicy\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"" >>clean.sh
	else
		echo "#!/usr/bin/env bash

# Kill all sockets
rm -rf "${name}-monitor.socket"
rm -rf "${name}-serial.socket"
rm -rf "${name}-agent.sock"
rm -rf "${name}.socket"

# Kill any running python script qemu spicy
ps aux | grep \"qemu\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"
ps aux | grep \"spicy\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"

qemu-system-x86_64 \\
    -name "${name}",process=${name} \\
    -enable-kvm -machine q35,smm=off,vmport=off -cpu host,kvm=on,topoext \\
    -smp cores=${cores},threads=${threads},sockets=1 -m ${ram} -device virtio-balloon \\
    -vga ${vga} \\
    -display none \\
    -audiodev spice,id=audio0 \\
    -device intel-hda \\
    -device hda-duplex,audiodev=audio0 \\
    -rtc base=localtime,clock=host,driftfix=slew \\
    -spice disable-ticketing=on,port=5930,addr=127.0.0.1 \\
    -device virtio-serial-pci \\
    -chardev socket,id=agent0,path="${name}-agent.sock",server=on,wait=off \\
    -device virtserialport,chardev=agent0,name=org.qemu.guest_agent.0 \\
    -chardev spicevmc,id=vdagent0,name=vdagent \\
    -device virtserialport,chardev=vdagent0,name=com.redhat.spice.0 \\
    -chardev spiceport,id=webdav0,name=org.spice-space.webdav.0 \\
    -device virtserialport,chardev=webdav0,name=org.spice-space.webdav.0 \\
    -device virtio-rng-pci,rng=rng0 \\
    -object rng-random,id=rng0,filename=/dev/urandom \\
    -device qemu-xhci,id=spicepass -chardev spicevmc,id=usbredirchardev1,name=usbredir \\
    -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \\
    -chardev spicevmc,id=usbredirchardev2,name=usbredir \\
    -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \\
    -chardev spicevmc,id=usbredirchardev3,name=usbredir \\
    -device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \\
    -device pci-ohci,id=smartpass -device usb-ccid \\
    -chardev spicevmc,id=ccid,name=smartcard \\
    -device ccid-card-passthru,chardev=ccid \\
    -device usb-ehci,id=input \\
    -device usb-kbd,bus=input.0 \\
    -k en-us \\
    -device usb-mouse,bus=input.0 -device virtio-net,netdev=nic \\
    -netdev user,hostname="${name}",hostfwd=tcp::22220-:22,id=nic \\
    -global driver=cfi.pflash01,property=secure,value=on -drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \\
    -drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \\
    -device virtio-blk-pci,drive=SystemDisk -drive id=SystemDisk,if=none,format=qcow2,file=Image.img \\
    -fsdev local,id=fsdev0,path=/home/$USER/Public,security_model=mapped-xattr \\
    -device virtio-9p-pci,fsdev=fsdev0,mount_tag=Public-$USER \\
    -monitor unix:"${name}-monitor.socket",server,nowait \\
    -serial unix:"${name}-serial.socket",server,nowait \\
    -drive media=cdrom,index=0,file=${name}.iso \\
    -drive file=fat:rw:${VMS_PATH}/${name}/sharedFolder,format=raw &

# Open Spice Window
        setsid spicy -p 5930 --title="${name}" &" >>start.sh

		chmod +x start.sh

		### Cleanup Script

		touch clean.sh

		echo "#!/usr/bin/env bash

# Kill all sockets
rm -rf "${name}-monitor.socket"
rm -rf "${name}-serial.socket"
rm -rf "${name}-agent.sock"
rm -rf "${name}.socket"

# Kill any running python script qemu spicy
ps aux | grep \"qemu\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"
        ps aux | grep \"spicy\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"" >>clean.sh

	fi

	chmod +x clean.sh

	#### Include a minimal start Script

	touch fallback-start.sh
	echo "#!/usr/bin/env bash
qemu-system-x86_64 -enable-kvm \\
	-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \\
	-machine q35,accel=kvm,smm=on \\
	-cpu host \\
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

	#### Include a minimal start Script (BIOS)

	touch fallback-start-BIOS.sh
	echo "#!/usr/bin/env bash
qemu-system-x86_64 -enable-kvm \\
	-machine q35,accel=kvm,smm=on \\
	-cpu host \\
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
	echo "${isWindows}" >>"${CONFIG_FILE}"
}

takeInput() {
	echo "Enter cores to use: (Default 4)"
	read _cores

	echo "Enter threads to use: (Default 2)"
	read _threads

	echo "Enter ram to use: (Default 4G)"
	read _ram

	if [[ "$1" == "resize" ]]; then
		echo "By how much the disk size to be increased : [Enter something sensisble like 100G(in gigabytes),100M(in megabytes),100K(in kilobytes)]"
		read _diskSize
		qemu-img resize ./Image.img "+${_diskSize}"
	else
		echo "Enter Disk Size to use: (Default 30G) [Enter something sensisble like 100G(in gigabytes),100M(in megabytes),100K(in kilobytes)]"
		read _diskSize

	fi

	echo "Enter video drivers to use: (Default virtio) [virtio/qxl]"
	read _vga

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

}

takeCliArguments() {
	echo "Are you trying to install windows?: [yes,y/no,n]"
	read _isWindows

	if [[ "$_isWindows" != "" ]]; then
		if [[ "$_isWindows" == "no" || "$_isWindows" == "n" || "$_isWindows" == "yes" || "$_isWindows" == "y" ]]; then
			isWindows="$_isWindows"
		else
			echo "Please Enter Properly if you are trying to install Windows or not!"
			exit 0
		fi
	fi

	# Get ISO Location
	isoLocation=$(fd --type f . $HOME | fzf --prompt "Choose ISO Location:" --reverse --preview "bat --theme gruvbox-dark --style numbers,changes --color=always {}" | xargs -I {} realpath "{}")

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
	isWindows=$(sed -n '6p' <"$CONFIG_FILE")

	find . -maxdepth 1 ! -name '*.iso' ! -name '*.img' ! -type d -delete
	addScripts

else
	if [[ "$reconfigure" == "no" ]]; then
		takeCliArguments
	else
		cd "${goto}"
		takeInput "resize"
		configPath="${goto}/${CONFIG_FILE}"
		isWindows=$(sed -n '6p' <"$configPath")
		find . -maxdepth 1 ! -name '*.iso' ! -name '*.img' ! -type d -delete
		addScripts
	fi

fi
