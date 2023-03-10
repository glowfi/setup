# VIRTUALIZATION

## INSTALL

#### ULTRA MINIMAL

```bash
yay -S --noconfirm quickemu quickgui-bin qemu-audio-pa qemu-ui-sdl
```

#### MINIMAL

```bash
sudo pacman -S --noconfirm qemu-base edk2-ovmf qemu-ui-sdl spice spice-gtk spice-vdagent
```

#### FULL

```bash
sudo pacman -S dnsmasq virt-manager qemu-base ebtables edk2-ovmf qemu-ui-sdl spice spice-gtk spice-vdagent
sudo usermod -G libvirt -a "$USER"
sudo systemctl start libvirtd
```

## UNINSTALL

```bash
sudo pacman -Rns dnsmasq virt-manager qemu-base edk2-ovmf qemu-ui-sdl
sudo gpasswd -d "$USER" libvirt
```

## CONFIGURE

#### CREATE QCOW

```bash
cp -r /usr/share/edk2-ovmf/x64/OVMF_VARS.fd .
qemu-img create -f qcow2 Image.img 20G
```

#### QEMU CLI COMMAND (SIMPLE VIRTUALIZATION)

```bash
qemu-system-x86_64 -enable-kvm \
	-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	-machine q35,accel=kvm,smm=on \
	-cpu host \
	-boot menu=on \
	-global driver=cfi.pflash01,property=secure,value=on \
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \
	-drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \
	-drive file=Image.img \
	-m 8G \
	-smp 6 \
	-vga virtio \
	-display sdl,gl=on \
	-cdrom ISO_NAME
```

#### GPU PASSTHROUGH GUIDE

##### Virtio drivers iso By Redhat

```
https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md
```

#### SCRIPT TO AUTOMATE PASSTHROUGH

```bash
#!/bin/bash

if [[ "$1" = "pass" ]]; then

	## EDIT GRUB
	sudo sed -i '6s/.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 lsm=landlock,lockdown,yama,apparmor,bpf amd_iommu=on vfio-pci.ids=10de:25a2,10de:2291"/' /etc/default/grub
	sudo grub-mkconfig -o /boot/grub/grub.cfg

	## EDIT vfio.conf
	sudo -E nvim -c ":q" /etc/modprobe.d/vfio.conf
	sudo echo | sudo tee /etc/modprobe.d/vfio.conf >/dev/null
	sudo echo "options vfio-pci ids=10de:25a2,10de:2291" | sudo tee -a /etc/modprobe.d/vfio.conf >/dev/null
	sudo echo "softdep nvidia pre: vfio-pci" | sudo tee -a /etc/modprobe.d/vfio.conf >/dev/null
	sudo sed -i "1d" /etc/modprobe.d/vfio.conf
	sudo mkinitcpio -p linux-zen
else

	## EDIT GRUB
	sudo sed -i '6s/.*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 lsm=landlock,lockdown,yama,apparmor,bpf"/' /etc/default/grub
	sudo grub-mkconfig -o /boot/grub/grub.cfg

	## DELETE vfio.conf
	sudo rm -rf /etc/modprobe.d/vfio.conf
	sudo mkinitcpio -p linux-zen
fi
```

#### QEMU CLI COMMAND (PASSTHROUGH VIRTUALIZATION)

<b>Without Audio</b>

```bash
sudo qemu-system-x86_64 \
	-enable-kvm \
	-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	-machine q35,accel=kvm,smm=on \
	-cpu host \
	-m 10G \
	-smp 6 \
	-vga virtio \
	-display sdl,gl=on \
	-boot menu=on \
	-device vfio-pci,host=01:00.0,multifunction=on \
	-device vfio-pci,host=01:00.1 \
	-serial none \
	-parallel none \
	-global driver=cfi.pflash01,property=secure,value=on \
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \
	-drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \
	-drive file=Image.img \
	-drive file=win10.iso,index=1,media=cdrom \
	-drive file=virtio.iso,index=2,media=cdrom
```

<b>With Audio Passthrough</b>

```bash
sudo qemu-system-x86_64 \
	-enable-kvm \
	-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	-machine q35,accel=kvm,smm=on \
	-cpu host \
	-m 10G \
	-smp 6 \
	-vga virtio \
	-display sdl \
	-boot menu=on \
    -audiodev id=audio1,driver=spice \
    -spice port=5900,addr=127.0.0.1,disable-ticketing=on,image-compression=off,seamless-migration=on \
    -device ich9-intel-hda,id=sound0,bus=pcie.0,addr=0x1b -device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0 \
    -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 \
	-device vfio-pci,host=01:00.0,multifunction=on \
	-device vfio-pci,host=01:00.1 \
	-serial none \
	-parallel none \
	-global driver=cfi.pflash01,property=secure,value=on \
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \
	-drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \
	-drive file=Image.img \
	-cdrom win10.iso
```

### BSD Virtualization

<b>Simple Virtualization (Audio Not Working)</b>

```bash
qemu-system-x86_64 \
	-enable-kvm \
	-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	-machine q35,accel=kvm,smm=on \
	-cpu host \
	-m 10G \
	-smp 6 \
	-vga virtio \
	-display sdl,gl=on \
	-boot menu=on \
	-serial none \
	-parallel none \
	-global driver=cfi.pflash01,property=secure,value=on \
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \
	-drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \
	-drive file=Image.img \
    -device virtio-net,netdev=vmnic -netdev user,id=vmnic,hostfwd=tcp::5222-:22 \
	-cdrom NAME
```

<b>Virtualization with QXL (Audio Not Working)</b>

```bash
qemu-system-x86_64 \
	-enable-kvm \
	-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	-machine q35,accel=kvm,smm=on \
	-cpu host \
	-m 10G \
	-smp 6 \
	-device qxl-vga,ram_size=65536,vram_size=65536,vgamem_mb=64 \
	-display none \
	-boot menu=on \
	-serial none \
	-parallel none \
	-global driver=cfi.pflash01,property=secure,value=on \
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \
	-drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \
	-drive file=Image.img \
	-audiodev spice,id=audio0 \
	-device intel-hda \
	-device hda-duplex,audiodev=audio0 \
	-spice port=5900,addr=127.0.0.1,disable-ticketing=on,image-compression=off,seamless-migration=on \
	-device virtio-net,netdev=vmnic -netdev user,id=vmnic,hostfwd=tcp::5222-:22 \
	-cdrom gbsd.iso
```

<b>Virtualization with Virtio (GPU Passthrough)</b>

```bash
sudo qemu-system-x86_64 \
	-enable-kvm \
	-bios /usr/share/edk2-ovmf/x64/OVMF_CODE.fd \
	-machine q35,accel=kvm,smm=on \
	-cpu host \
	-m 10G \
	-smp 6 \
	-vga virtio \
	-display sdl,gl=on \
	-boot menu=on \
	-device vfio-pci,host=01:00.0,multifunction=on \
	-device vfio-pci,host=01:00.1 \
	-serial none \
	-parallel none \
	-global driver=cfi.pflash01,property=secure,value=on \
	-drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \
	-drive if=pflash,format=raw,unit=1,file=OVMF_VARS.fd \
	-drive file=Image.img \
    -device virtio-net,netdev=vmnic -netdev user,id=vmnic,hostfwd=tcp::5222-:22 \
	-cdrom NAME
```

<b>UEFI BSD (Audio Working)</b>

```bash
qemu-system-x86_64 \
	-name ghostbsd-22.01.12-mate,process=ghostbsd-22.01.12-mate \
	-enable-kvm -machine q35,smm=off,vmport=off -cpu host,kvm=on,topoext \
	-smp cores=4,threads=2,sockets=1 -m 4G -device virtio-balloon \
	-vga none \
	-device qxl-vga,ram_size=65536,vram_size=65536,vgamem_mb=64 \
	-display none \
	-audiodev spice,id=audio0 \
	-device intel-hda \
	-device hda-duplex,audiodev=audio0 \
	-rtc base=localtime,clock=host,driftfix=slew \
	-spice disable-ticketing=on,port=5930,addr=127.0.0.1 \
	-device virtio-serial-pci \
	-chardev socket,id=agent0,path=ghostbsd-22.01.12-mate/ghostbsd-22.01.12-mate-agent.sock,server=on,wait=off \
	-device virtserialport,chardev=agent0,name=org.qemu.guest_agent.0 \
	-chardev spicevmc,id=vdagent0,name=vdagent \
	-device virtserialport,chardev=vdagent0,name=com.redhat.spice.0 \
	-chardev spiceport,id=webdav0,name=org.spice-space.webdav.0 \
	-device virtserialport,chardev=webdav0,name=org.spice-space.webdav.0 \
	-device virtio-rng-pci,rng=rng0 \
	-object rng-random,id=rng0,filename=/dev/urandom \
	-device qemu-xhci,id=spicepass -chardev spicevmc,id=usbredirchardev1,name=usbredir \
	-device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \
	-chardev spicevmc,id=usbredirchardev2,name=usbredir \
	-device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \
	-chardev spicevmc,id=usbredirchardev3,name=usbredir \
	-device usb-redir,chardev=usbredirchardev3,id=usbredirdev3 \
	-device pci-ohci,id=smartpass -device usb-ccid \
	-chardev spicevmc,id=ccid,name=smartcard \
	-device ccid-card-passthru,chardev=ccid \
	-device usb-ehci,id=input \
	-device usb-kbd,bus=input.0 \
	-k en-us \
	-device usb-mouse,bus=input.0 -device virtio-net,netdev=nic \
	-netdev user,hostname=ghostbsd-22.01.12-mate,hostfwd=tcp::22220-:22,id=nic \
	-global driver=cfi.pflash01,property=secure,value=on -drive if=pflash,format=raw,unit=0,file=/usr/share/edk2-ovmf/x64/OVMF_CODE.fd,readonly=on \
	-drive if=pflash,format=raw,unit=1,file=ghostbsd-22.01.12-mate/OVMF_VARS.fd \
	-drive media=cdrom,index=0,file=ghostbsd-22.01.12-mate/GhostBSD-22.01.12.iso \
	-device virtio-blk-pci,drive=SystemDisk -drive id=SystemDisk,if=none,format=qcow2,file=ghostbsd-22.01.12-mate/disk.qcow2 \
	-fsdev local,id=fsdev0,path=/home/$USER/Public,security_model=mapped-xattr \
	-device virtio-9p-pci,fsdev=fsdev0,mount_tag=Public-$USER \
	-monitor unix:ghostbsd-22.01.12-mate/ghostbsd-22.01.12-mate-monitor.socket,server,nowait \
	-serial unix:ghostbsd-22.01.12-mate/ghostbsd-22.01.12-mate-serial.socket,server,nowait # -pidfile ghostbsd-22.01.12-mate/ghostbsd-22.01.12-mate.pid \
```

### FIREFOX

```bash
#!/bin/bash

# Settings

original=$(echo 'user_pref("keyword.enabled", false);')
required=$(echo 'user_pref("keyword.enabled", true);')

# Get Default-release Location

findLocation=$(find ~/.mozilla/firefox/ | grep -E "default-release" | head -1)

# Activate Settings

cd "$findLocation"
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js
sed -i "s/$original/$required/g" user.js
cd
```

## UNINSTALL

#### UNINSTALL NNN FM

```bash
sudo rm -rf /usr/local/bin/nnn
sudo rm -rf /usr/local/share/man/man1/nnn.1
sudo rm -rf .config/nnn
```

#### UNINSTALL NEOVIM

```bash
sudo rm /usr/local/bin/nvim
sudo rm -r /usr/local/share/nvim/
```

### MIRACLE CAST

```bash
### INSTALL
yay -S --noconfirm miraclecast-git

git clone https://github.com/albfan/miraclecast
cd miraclecast
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr ..
make
sudo make install
cd ..
cd ..
rm -rf miraclecast

### RUN
systemctl stop NetworkManager.service
systemctl stop wpa_supplicant.service
sudo miracled
sudo miracle-wifid &
sudo miracle-sinkctl

### RESTART
systemctl start NetworkManager.service
systemctl start wpa_supplicant.service

### UNINSTALL
sudo pacman -Rns android-tools scrcpy
yay -Rns miraclecast-git
fd "miracle" /usr/bin/ | xargs sudo rm -rf
sudo rm -rf /usr/bin/gstplayer
sudo rm -rf /usr/bin/uibc-viewer
sudo rm -rf /usr/share/bash-completion/completions/miracle-sinkctl
sudo rm -rf /usr/share/bash-completion/completions/miracle-wifictl
sudo rm -rf /usr/share/bash-completion/completions/miracle-wifid
```

### HDMI

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 lsm=landlock,lockdown,yama,apparmor,bpf nvidia-drm.modeset=1"
xrandr --output "HDMI-1-0" --mode 1920x1080
```

### JELLYFIN MEDIA SERVER

```bash
yay -S --noconfirm jellyfin-bin jellyfin-media-player
pip install --upgrade jellyfin-mpv-shim
sudo chmod -R a+rx /run/media/ && sudo systemctl start jellyfin.service
```

### PROTON ARGUMENTS

##### ENABLE

-   RTX
-   DLSS
-   Use Discrete GPU ONLY (NVIDIA)

```bash
PROTON_HIDE_NVIDIA_GPU=0 PROTON_ENABLE_NVAPI=1 __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json gamemoderun MANGOHUD=1 %command%
```