#!/usr/bin/env bash


cores="4"
threads="2"
ram="4G"
vga="virtio"

echo "Enter the name of the virtual machine: [Do not give spaces while naming]"
read name

echo "Enter cores to use: (Default 4)"
read _cores

echo "Enter threads to use: (Default 2)"
read _threads

echo "Enter ram to use: (Default 4G)"
read _ram

echo "Enter video drivers to use: (Default Virtio) [Virtio/QXL]"
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

if [[ "$_vga" != "" ]]; then
    vga="$_vga"
fi


name=$(echo "$name" | tr " " "-")

# Create Directory if not exits
mkdir -p $HOME/Downloads/VMS/


# Go to VMS Directory
cd $HOME/Downloads/VMS/

mkdir "${name}"
cd "${name}"

### Create QCOW

cp -r /usr/share/edk2-ovmf/x64/OVMF_VARS.fd .
qemu-img create -f qcow2 Image.img 20G


### Start Script

touch start.sh

echo "#!/usr/bin/env bash

# Kill all sockets
rm -rf "${name}-monitor.socket"
rm -rf "${name}-serial.socket"
rm -rf "${name}-agent.sock"
rm -rf "${name}.socket"

# Kill any running python script qemu spicy
ps aux | grep \"createsocket.py\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"
ps aux | grep \"qemu\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"
ps aux | grep \"spicy\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"

# Create Main socket
setsid python createsocket.py &

# Create the monitor socket file
monitor_socket=\"${name}-monitor.socket\"
if [ ! -e \"\$monitor_socket\" ]; then
    mkfifo \"\$monitor_socket\"
fi

# Create the serial socket file
serial_socket=\"${name}-serial.socket\"
if [ ! -e \"\$serial_socket\" ]; then
    mkfifo \"\$serial_socket\"
fi

qemu-system-x86_64 \\
    -name "${name}",process=${name} \\
    -enable-kvm -machine q35,smm=off,vmport=off -cpu host,kvm=on,topoext \\
    -smp cores=${cores},threads=${threads},sockets=1 -m ${ram} -device virtio-balloon \\
    -display none,gl=on \\
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
    -device virtio-blk-pci,drive=SystemDisk -drive id=SystemDisk,if=none,format=qcow2,file=Image.img\\
    -fsdev local,id=fsdev0,path=/home/$USER/Public,security_model=mapped-xattr \\
    -device virtio-9p-pci,fsdev=fsdev0,mount_tag=Public-$USER \\
    -monitor unix:"${name}.socket",server,nowait \\
    -serial unix:"${name}.socket",server,nowait \\
    -drive media=cdrom,index=0,file=void.iso &

# Open Spice Window
setsid spicy -p 5930 --title="${name}" &" >> start.sh

chmod +x start.sh


### Cleanup Script

touch clean.sh

echo "#!/usr/bin/env bash

# rm -rf Image.img
# qemu-img create -f qcow2 Image.img 30

# Kill all sockets
rm -rf "${name}-monitor.socket"
rm -rf "${name}-serial.socket"
rm -rf "${name}-agent.sock"
rm -rf "${name}.socket"

# Kill any running python script qemu spicy
ps aux | grep \"createsocket.py\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"
ps aux | grep \"qemu\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"
ps aux | grep \"spicy\"|head -1 | awk -F\" \" '{print \$2}'|xargs -I{} kill -9 \"{}\"" >> clean.sh

chmod +x clean.sh


### Socket Script

touch createsocket.py

echo "import socket

# create a socket object
sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

# specify the path for the socket file
sock_path = \"${name}-agent.sock\"

# bind the socket to the specified path
sock.bind(sock_path)

# listen for incoming connections
sock.listen(1)

# accept incoming connections
conn, addr = sock.accept()

# use the connection object to send or receive data
# ...

# close the connection and socket
conn.close()
sock.close()" >> createsocket.py

cd ..
