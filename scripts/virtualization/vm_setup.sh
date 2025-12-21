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
	cp -r /usr/share/edk2-ovmf/x64/OVMF_VARS.4m.fd .

	### Start Script

	touch start.sh
	touch start_secboot.sh

	### Check vga type

	if [[ "$vga" == "qxl" ]]; then
		videoSettings="-vga qxl \\"
		spiceSettings="-spice unix=on,addr=/run/user/1000/${name}-agent.sock,disable-ticketing=on,image-compression=off,gl=off,seamless-migration=on \\"
	elif [[ "$vga" == "virtio" ]]; then
		### Check GPU
		if [[ "$gpu" = "Software" || "$gpu" = "" ]]; then
			videoSettings="-device virtio-vga \\"
			spiceSettings="-spice unix=on,addr=/run/user/1000/${name}-agent.sock,disable-ticketing=on,image-compression=off,gl=off,seamless-migration=on \\"
		else
			videoSettings="-device virtio-vga-gl \\"
			spiceSettings="-spice unix=on,addr=/run/user/1000/${name}-agent.sock,disable-ticketing=on,image-compression=off,gl=on,rendernode=/dev/dri/by-path/pci-${gpu}-render,seamless-migration=on \\"
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

	### Network Script
	cat <<'EOF' >>qemu-net.sh
#!/bin/bash

BRIDGE=br0
GATEWAY=192.168.53.1
NETWORK=192.168.53.0/24
DHCP_START=192.168.53.50
DHCP_END=192.168.53.150
DNS="8.8.8.8,1.1.1.1"
WIFI=$(ip route | grep default | awk '{print $5}' | head -1)
USER_NAME=${SUDO_USER:-$(logname)}

start() {
	echo "[+] Starting network setup..."

	# ---- Bridge ----
	if ! ip link show "$BRIDGE" &>/dev/null; then
		echo "[+] Creating bridge $BRIDGE"
		ip link add "$BRIDGE" type bridge
	else
		echo "[=] Bridge $BRIDGE already exists"
	fi

	# Assign IP only if not present
	if ! ip addr show "$BRIDGE" | grep -q "$GATEWAY/24"; then
		ip addr flush dev "$BRIDGE"
		ip addr add "$GATEWAY/24" dev "$BRIDGE"
	else
		echo "[=] Bridge IP already configured"
	fi

	ip link set "$BRIDGE" up

	# ---- IP Forwarding ----
	if [ "$(sysctl -n net.ipv4.ip_forward)" != "1" ]; then
		echo "[+] Enabling IPv4 forwarding"
		sysctl -qw net.ipv4.ip_forward=1
	else
		echo "[=] IPv4 forwarding already enabled"
	fi

	# ---- nftables NAT ----
	if ! nft list table ip qemu-nat &>/dev/null; then
		echo "[+] Creating nftables NAT table"
		nft -f - <<-NFT
			table ip qemu-nat {
				chain postrouting {
					type nat hook postrouting priority 100;
					ip saddr $NETWORK oifname "$WIFI" masquerade
				}
			}
		NFT
	else
		echo "[=] nftables NAT table already exists"
	fi

	# ---- Forwarding rules (custom table assumed to exist) ----
	if ! nft list chain inet my_table my_forward 2>/dev/null | grep -q "iifname \"$BRIDGE\""; then
		nft add rule inet my_table my_forward iifname "$BRIDGE" accept
	fi

	if ! nft list chain inet my_table my_forward 2>/dev/null | grep -q "oifname \"$BRIDGE\""; then
		nft add rule inet my_table my_forward oifname "$BRIDGE" accept
	fi

	# ---- dnsmasq ----
	if [ -f /run/qemu-dnsmasq.pid ] && kill -0 "$(cat /run/qemu-dnsmasq.pid)" 2>/dev/null; then
		echo "[=] dnsmasq already running"
	else
		echo "[+] Starting dnsmasq"
		dnsmasq \
			--interface="$BRIDGE" \
			--bind-interfaces \
			--listen-address="$GATEWAY" \
			--dhcp-range="$DHCP_START","$DHCP_END",12h \
			--dhcp-option=option:router,"$GATEWAY" \
			--dhcp-option=option:dns-server,"$DNS" \
			--server=127.0.0.1#5353 \
			--pid-file=/run/qemu-dnsmasq.pid \
			--dhcp-leasefile=/var/lib/misc/dnsmasq.leases \
			--conf-file=/dev/null \
			--port=0
	fi

	echo "✔ Network ready. Use: $0 create"
}

stop() {
	echo "[+] Stopping network..."

	# ---- dnsmasq ----
	if [ -f /run/qemu-dnsmasq.pid ] && kill -0 "$(cat /run/qemu-dnsmasq.pid)" 2>/dev/null; then
		echo "[+] Stopping dnsmasq"
		kill "$(cat /run/qemu-dnsmasq.pid)"
	else
		echo "[=] dnsmasq already stopped"
	fi

	rm -f /run/qemu-dnsmasq.pid /var/lib/misc/dnsmasq.leases

	# ---- TAP devices ----
	for tap in $(ip -o link show | awk -F': ' '{print $2}' | grep '^tap'); do
		echo "[+] Removing $tap"
		ip link del "$tap"
	done

	# ---- Bridge ----
	if ip link show "$BRIDGE" &>/dev/null; then
		echo "[+] Removing bridge $BRIDGE"
		ip link del "$BRIDGE"
	else
		echo "[=] Bridge already removed"
	fi

	# ---- nftables ----
	if nft list table ip qemu-nat &>/dev/null; then
		echo "[+] Removing nftables NAT table"
		nft delete table ip qemu-nat
	else
		echo "[=] NAT table already removed"
	fi

	if nft list chain inet my_table my_forward &>/dev/null; then
		for h in $(nft -a list chain inet my_table my_forward | grep "$BRIDGE" | awk '{print $NF}'); do
			nft delete rule inet my_table my_forward handle "$h"
		done
	fi

	echo "✔ Network stopped"
}

create_tap() {
	# Find next available tap number
	i=0
	while ip link show tap$i &>/dev/null; do ((i++)); done

	ip tuntap add dev tap$i mode tap user $USER_NAME
	ip link set tap$i up master $BRIDGE
	echo "tap$i"
}

remove_tap() {
	[ -z "$1" ] && {
		echo "Usage: $0 remove <tap>"
		exit 1
	}
	ip link del $1 2>/dev/null && echo "Removed $1"
}

status() {
	echo "=== Bridge ==="
	ip -br addr show $BRIDGE 2>/dev/null || echo "Down"
	echo -e "\n=== Active TAPs ==="
	ip -br link show | grep tap || echo "None"
	echo -e "\n=== DHCP Leases ==="
	cat /var/lib/misc/dnsmasq.leases 2>/dev/null || echo "Empty"
}

case "$1" in
start) start ;;
stop) stop ;;
restart)
	stop
	sleep 1
	start
	;;
status) status ;;
create) create_tap ;;
remove) remove_tap "$2" ;;
*) echo "Usage: $0 {start|stop|restart|status|create|remove <tap>}" ;;
esac
EOF

	chmod +x qemu-net.sh

	MAC="$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)))"

	### Startup script [UEFI+Secure Boot Disabled]

	echo "#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd)\"
QEMU_NET=\"\$SCRIPT_DIR/qemu-net.sh\"
PID_FILE="${name}.pid"

cleanup() {
	echo \"[+] Cleaning up...\"

	# Remove PID file only if it belongs to us
	if [[ -n \"\${QEMU_PID:-}\" ]] && [[ -f \"\$PID_FILE\" ]]; then
		rm -f \"\$PID_FILE\"
	fi

	# Remove ONLY the TAP we created
	if [[ -n \"\${TAP:-}\" ]]; then
		echo \"[+] Removing TAP \$TAP\"
		sudo -A \"\$QEMU_NET\" remove \"\$TAP\" || true
	fi
}

trap cleanup EXIT INT TERM

# Kill all sockets
rm -rf "${name}-agent.sock"

# Check if this VM is already running
if [[ -f \"\$PID_FILE\" ]]; then
	old_pid=\"\$(cat \"\$PID_FILE\")\"
	if ps -p \"\$old_pid\" >/dev/null 2>&1; then
		echo \"[!] Rocky VM already running (PID=\$old_pid). Exiting.\"
		exit 0
	else
		echo \"[!] Stale PID file found. Removing.\"
		rm -f \"\$PID_FILE\"
	fi
fi

VM_MAC="${MAC}"

# Start networking
sudo -A \"\$QEMU_NET\" start

# ---- Create TAP ----
TAP=\"\$(sudo -A \"\$QEMU_NET\" create)\"
echo \"[+] Using TAP: \$TAP\"

# Startup script
qemu-system-x86_64 \\
    -name "${name}",process=${name} \\
	-enable-kvm -machine q35,smm=on,vmport=off,hpet=off,acpi=on -cpu host,kvm=on,migratable=on,topoext \\
    -overcommit mem-lock=off -smp cores=${cores},threads=${threads},sockets=1 -m ${ram} -device virtio-balloon \\
    ${videoSettings}
    -netdev tap,id=net0,ifname=\"\$TAP\",script=no,downscript=no \\
	-device virtio-net-pci,netdev=net0,mac=\"\$VM_MAC\" \\
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
    -global driver=cfi.pflash01,property=secure,value=on -drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd,readonly=on \\
    -drive if=pflash,format=raw,unit=1,file=OVMF_VARS.4m.fd \\
	-drive file=Image.img \\
	-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \\
    ${_iso_sharedfolder_string}

QEMU_PID=\$!
echo \"[+] QEMU started (PID=\$QEMU_PID)\"

# Open viewer
remote-viewer spice+unix:///run/user/1000/${name}-agent.sock &

# Wait for QEMU to exit
wait \"\$QEMU_PID\"
echo \"[+] QEMU exited\"" >>start.sh

	chmod +x start.sh

	### Startup script [UEFI+Secure Boot Enabled]

	echo "#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR=\"\$(cd \"\$(dirname \"\${BASH_SOURCE[0]}\")\" && pwd)\"
QEMU_NET=\"\$SCRIPT_DIR/qemu-net.sh\"
PID_FILE="${name}.pid"

cleanup() {
	echo \"[+] Cleaning up...\"

	# Remove PID file only if it belongs to us
	if [[ -n \"\${QEMU_PID:-}\" ]] && [[ -f \"\$PID_FILE\" ]]; then
		rm -f \"\$PID_FILE\"
	fi

	# Remove ONLY the TAP we created
	if [[ -n \"\${TAP:-}\" ]]; then
		echo \"[+] Removing TAP \$TAP\"
		sudo -A \"\$QEMU_NET\" remove \"\$TAP\" || true
	fi
}

trap cleanup EXIT INT TERM

# Kill all sockets
rm -rf "${name}-agent.sock"

# Check if this VM is already running
if [[ -f \"\$PID_FILE\" ]]; then
	old_pid=\"\$(cat \"\$PID_FILE\")\"
	if ps -p \"\$old_pid\" >/dev/null 2>&1; then
		echo \"[!] Rocky VM already running (PID=\$old_pid). Exiting.\"
		exit 0
	else
		echo \"[!] Stale PID file found. Removing.\"
		rm -f \"\$PID_FILE\"
	fi
fi

VM_MAC="${MAC}"

# Start networking
sudo -A \"\$QEMU_NET\" start

# ---- Create TAP ----
TAP=\"\$(sudo -A \"\$QEMU_NET\" create)\"
echo \"[+] Using TAP: \$TAP\"

# Startup script
qemu-system-x86_64 \\
    -name "${name}",process=${name} \\
	-enable-kvm -machine q35,smm=on,vmport=off,hpet=off,acpi=on -cpu host,kvm=on,migratable=on,topoext \\
    -overcommit mem-lock=off -smp cores=${cores},threads=${threads},sockets=1 -m ${ram} -device virtio-balloon \\
    ${videoSettings}
    -netdev tap,id=net0,ifname=\"\$TAP\",script=no,downscript=no \\
	-device virtio-net-pci,netdev=net0,mac=\"\$VM_MAC\" \\
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
    -global driver=cfi.pflash01,property=secure,value=on -drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.secboot.4m.fd,readonly=on \\
    -drive if=pflash,format=raw,unit=1,file=OVMF_VARS.4m.fd \\
	-drive file=Image.img \\
	-sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny \\
    ${_iso_sharedfolder_string}


        # Open remote viewer
        remote-viewer spice+unix:///run/user/1000/spice.sock &

QEMU_PID=\$!
echo \"[+] QEMU started (PID=\$QEMU_PID)\"

# Open viewer
remote-viewer spice+unix:///run/user/1000/${name}-agent.sock &

# Wait for QEMU to exit
wait \"\$QEMU_PID\"
echo \"[+] QEMU exited\"" >>start_secboot.sh

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
	-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd \\
	-machine q35,accel=kvm,smm=on \\
	-cpu host \\
	-device ich9-intel-hda,id=sound0,bus=pcie.0,addr=0x1b -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0 \\
    -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 \\
	-boot menu=on \\
	-global driver=cfi.pflash01,property=secure,value=on \\
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.4m.fd,readonly=on \\
	-drive if=pflash,format=raw,unit=1,file=OVMF_VARS.4m.fd \\
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
	THEME=$(echo "gruvbox-dark") # gruvbox-dark
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
