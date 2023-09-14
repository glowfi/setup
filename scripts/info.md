# VIRTUALIZATION

## INSTALL

### MINIMAL (With only quickemu)

```bash
yay -S --noconfirm quickemu quickgui-bin qemu-audio-pa qemu-ui-sdl
```

### FULL

```bash
sudo pacman -S dnsmasq virt-manager qemu-base ebtables edk2-ovmf qemu-ui-sdl spice spice-gtk spice-vdagent qemu-hw-display-virtio-vga qemu-hw-display-virtio-vga-gl qemu-hw-display-virtio-gpu qemu-hw-display-virtio-gpu-gl virglrenderer virtiofsd qemu-hw-usb-smartcard qemu-hw-usb-redirect qemu-hw-usb-host qemu-ui-spice-app qemu-audio-spice
yay -S --noconfirm quickemu quickgui-bin qemu-audio-pa
sudo usermod -G libvirt -a "$USER"
sudo systemctl start libvirtd
cp -r $HOME/setup/scripts/virtualization/vm_download.sh $HOME/setup/scripts/virtualization/vm_setup.sh $HOME/setup/scripts/virtualization/vm_manager.sh $HOME/.local/bin
chmod +x $HOME/.local/bin/vm_download.sh $HOME/.local/bin/vm_setup.sh $HOME/.local/bin/vm_manager.sh
```

## UNINSTALL

```bash
sudo pacman -Rns dnsmasq virt-manager qemu-base ebtables edk2-ovmf qemu-ui-sdl spice spice-gtk spice-vdagent
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

# Arguments Help

```sh

### GPU Passthrough VFIO Devices

# Note
login as sudo to qemu
delete devices, set opengl off,delete drinode,vga none

# Passthrough arguments
-device vfio-pci,host=01:00.0,multifunction=on \
-device vfio-pci,host=01:00.1 \

# Add this if u want to use lookin glass
touch /dev/shm/looking-glass
chown root:kvm /dev/shm/looking-glass
chmod 660 /dev/shm/looking-glass


### Extras

# Delete everyting related to net netdev virtio-net devices to disable network Completely
-nic none \
-net none \
-nodefaults \

# Add Usb Devices
-usb -device usb-host,vendorid=0x,productid=0x \
-usb -device usb-tablet \
```

### FIREFOX

```bash

rm -rf $HOME/.mozilla
sudo rm -rf /usr/lib/firefox/

### Policies

sudo mkdir -p /usr/lib/firefox/distribution/
sudo touch /usr/lib/firefox/distribution/policies.json
echo '
{
	"policies": {
		"CaptivePortal": false,
		"DisableFirefoxAccounts": true,
		"DisableFirefoxStudies": true,
		"DisablePocket": true,
		"DisableTelemetry": true,
		"Extensions": {
			"Install": [
				"https://addons.mozilla.org/firefox/downloads/latest/tabliss/latest.xpi",
				"https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi",
				"https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi",
				"https://addons.mozilla.org/firefox/downloads/latest/libredirect/latest.xpi",
				"https://addons.mozilla.org/firefox/downloads/latest/leetcode-premium-unlocker/latest.xpi"
				]
		},
            "FirefoxHome": {
			"Search": true,
			"TopSites": false,
			"SponsoredTopSites": false,
			"Highlights": false,
			"Pocket": false,
			"SponsoredPocket": false,
			"Snippets": false,
			"Locked": false
		},
		"NetworkPrediction": false,
		"OverrideFirstRunPage": "about:home",
		"UserMessaging": {
			"WhatsNew": false,
			"ExtensionRecommendations": false,
			"FeatureRecommendations": false,
			"SkipOnboarding": false
		},
		"NoDefaultBookmarks":true
	}
}'| sudo tee -a /usr/lib/firefox/distribution/policies.json >/dev/null


###### Start Firefox ######

firefox &
sleep 6
killall firefox

###### Arkenfox Profile 1 ######

# Get Default-release Location
findLocation=$(find ~/.mozilla/firefox/ | grep -E "default-release" | head -1)

# Go to default-release profile
cd "$findLocation"

# User CSS
mkdir chrome
cd chrome
cd ..

# Get Arkenfox user.js
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js

# Scrape
homeURL=$(cat ./extension-settings.json | jq '.prefs.homepage_override.precedenceList' | grep -E "value"|awk -F":" '{print $2 ":" $3}' | tr -d ","|xargs)

# Settings
echo -e "\n" >> user.js
echo "// ****** OVERRIDES ******" >> user.js
echo "" >> user.js
echo 'user_pref("keyword.enabled", true);' >> user.js
echo "user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);" >> user.js
echo "user_pref('privacy.clearOnShutdown.cache', false);" >> user.js
echo "user_pref('privacy.clearOnShutdown.downloads', false);" >> user.js
echo "user_pref('privacy.clearOnShutdown.formdata', false);" >> user.js
echo "user_pref('privacy.clearOnShutdown.history', false);" >> user.js
echo "user_pref('privacy.clearOnShutdown.sessions', false);" >> user.js
echo "user_pref('privacy.clearOnShutdown.cookies', false);" >> user.js
echo "user_pref('privacy.clearOnShutdown.offlineApps', false);" >> user.js
echo "user_pref('browser.startup.homepage', '$homeURL');" >> user.js
echo "user_pref('browser.startup.page', 1);" >> user.js
echo 'user_pref("general.smoothScroll",                                       true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.enabled",                    true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant",  600);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",      650);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         25);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",      2.0);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",     250);' >> user.js
echo 'user_pref("general.smoothScroll.currentVelocityWeighting",              1.0);' >> user.js
echo 'user_pref("general.smoothScroll.stopDecelerationWeighting",             1.0);' >> user.js
echo 'user_pref("mousewheel.default.delta_multiplier_y",                      300);' >> user.js

cd

###### Arkenfox Profile 2 ######

# Create profile
firefox -CreateProfile second

# Get Default-release Location
findLocation=$(find ~/.mozilla/firefox/ | grep -E "second" | head -1)

# Go to second profile
cd "$findLocation"

# User CSS
mkdir chrome
cd chrome
cd ..

# Get Arkenfox user.js
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js

# Settings
echo -e "\n" >> user.js
echo "// ****** OVERRIDES ******" >> user.js
echo "" >> user.js
echo 'user_pref("keyword.enabled", true);' >> user.js
echo "user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);" >> user.js
echo 'user_pref("general.smoothScroll",                                       true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.enabled",                    true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant",  600);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",      650);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         25);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",      2.0);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",     250);' >> user.js
echo 'user_pref("general.smoothScroll.currentVelocityWeighting",              1.0);' >> user.js
echo 'user_pref("general.smoothScroll.stopDecelerationWeighting",             1.0);' >> user.js
echo 'user_pref("mousewheel.default.delta_multiplier_y",                      300);' >> user.js

cd

###### Betterfox Profile 3 ######

# Create profile
firefox -CreateProfile third

# Get Default-release Location
findLocation=$(find ~/.mozilla/firefox/ | grep -E "third" | head -1)

# Go to third profile
cd "$findLocation"

# User CSS
mkdir chrome
cd chrome
cd ..

# Get Betterfox user.js
wget "https://raw.githubusercontent.com/yokoffing/Betterfox/master/user.js" -O user.js

# Settings
echo -e "\n" >> user.js
echo "// ****** OVERRIDES ******" >> user.js
echo "" >> user.js
echo "user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);" >> user.js
echo 'user_pref("general.smoothScroll",                                       true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.enabled",                    true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant",  600);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",      650);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         25);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",      2.0);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",     250);' >> user.js
echo 'user_pref("general.smoothScroll.currentVelocityWeighting",              1.0);' >> user.js
echo 'user_pref("general.smoothScroll.stopDecelerationWeighting",             1.0);' >> user.js
echo 'user_pref("mousewheel.default.delta_multiplier_y",                      300);' >> user.js

cd

###### Normal Profile 4 ######

# Create profile
firefox -CreateProfile fourth


###### KEYBINDINGS ######

## Alternate Browser
#ctrl + alt + b
choice=$(printf "1.default-release : (ArkenFoxP) \n2.second : (ArkenFoxT)\n3.third : (BetterFOX)\n4.fourth : (Normal)"|dmenu -i -p "Choose Profile :" | awk -F":" '{print $1}'|awk -F"." '{print $2}'|xargs)
if [[ "$choice" != "" ]]; then
    firefox -P "$choice" &
    sleep 1
    if [ -f "/tmp/ffpid" ]; then
        echo "Do Not Do Anything ...!"
    else
        while true; do
            echo "$$" > /tmp/ffpid
            pgrep firefox > /dev/null
            if [ $? -ne 0 ]; then
                rm -rf /tmp/ffpid
                exit 0
            fi
            VOL=$(pamixer --get-volume)
            pactl list sink-inputs | grep -E 'Sink Input #|application.name = "Firefox"' | grep -oP '#\K\d+' | xargs -I{} pactl set-sink-input-volume {} "$VOL%"
        done
    fi
fi
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

# INSTALL
yay -S --noconfirm jellyfin-bin jellyfin-media-player
pip install --upgrade jellyfin-mpv-shim
sudo chmod -R a+rx /run/media/ && sudo systemctl start jellyfin.service

# UNINSTALL
yay -Rns --noconfirm jellyfin-bin jellyfin-media-player
pip uninstall jellyfin-mpv-shim
sudo rm -rf /var/cache/jellyfin /var/lib/jellyfin
```

### ARCHISO

```bash
sudo pacman -S --noconfirm archiso
mkdir customarch
cd customarch
mkdir {work,out}
sudo mkarchiso -v -w work -o out "$HOME/setup/configs/archlive"
```

### SystemD Service

```
echo -e "
[Unit]
Description=Test Service

[Service]
ExecStart=$HOME/script.sh
User=$USER
Restart=always

[Install]
WantedBy=multi-user.target
" | sudo tee /etc/systemd/system/mystartup.service >/dev/null


### Reload the systemd daemon and enable the service
sudo systemctl daemon-reload
sudo systemctl enable mystartup.service

```

### PROTON ARGUMENTS

##### ENABLE

-   RTX
-   DLSS
-   Use Discrete GPU ONLY (NVIDIA)
-   Vulkan Configured
-   Mangohud
-   Feral Gamemode

###### NORMAL PROTON

```bash
__NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json __GL_THREADED_OPTIMIZATIONS=1 PROTON_HIDE_NVIDIA_GPU=0 PROTON_ENABLE_NVAPI=1 gamemoderun MANGOHUD=1 %command%
```

###### PROTON GE

```bash
DXVK_ASYNC=1 __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json __GL_THREADED_OPTIMIZATIONS=1 PROTON_HIDE_NVIDIA_GPU=0 PROTON_ENABLE_NVAPI=1 gamemoderun MANGOHUD=1 %command%
```

# PYTHON DL MODULES

```fish
install "python-opencv" "pac"
install "cuda cudnn python-tensorflow-opt-cuda python-opt_einsum" "pac"
install "numactl" "pac"
for i in (seq 2)
pip install torch torchvision torchaudio
pip install opencv-contrib-python
end
```

# PYTHON STUBS

```fish
set loc (echo "/home/$USER/.local/lib/python3.10/site-packages/cv2")
curl -sSL "https://raw.githubusercontent.com/microsoft/python-type-stubs/main/cv2/__init__.pyi" -o "$loc/**init**.pyi"
pip install -U mypy
stubgen -m cv2
rm -rf out
```
