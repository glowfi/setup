# VIRTUALIZATION

## INSTALL

### MINIMAL (With only quickemu)

```bash
yay -S --noconfirm quickemu quickgui-bin qemu-audio-pa qemu-ui-sdl
```

### FULL

```bash
sudo pacman -S dnsmasq virt-manager qemu-base ebtables edk2-ovmf qemu-ui-sdl spice spice-gtk spice-vdagent qemu-hw-display-virtio-vga qemu-hw-display-virtio-vga-gl qemu-hw-display-virtio-gpu qemu-hw-display-virtio-gpu-gl qemu-hw-display-qxl virglrenderer qemu-hw-usb-redirect qemu-hw-usb-host qemu-ui-spice-app qemu-audio-spice virt-viewer
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
###### Extras ######

### Note
login as sudo to qemu
delete devices, set opengl off,delete drinode,vga none

### Passthrough arguments
-device vfio-pci,host=01:00.0,multifunction=on \
-device vfio-pci,host=01:00.1 \

### Audio Passthrough pulseaudio
-audiodev pa,server=unix:/run/user/1000/pulse/native,id=audio0

### Delete everyting related to net netdev virtio-net devices to disable network Completely
-nic none \
-net none \
-nodefaults \

### Add Usb Devices
-usb -device usb-host,vendorid=0x,productid=0x \
-usb -device usb-tablet \


###### Looking Glass Setup ######

###  Pre Looking Glass

+ Install Windows
+ Run Debloat amd reboot
+ Install DotNet,set security updates and reboot
+ Fully Update,install SPICE AGENTS and reboot

### Mid Step

+ Install looking-glass in main computer

### Install Dependencies
sudo pacman -S --noconfirm cmake gcc libgl libegl fontconfig spice-protocol make nettle pkgconf binutils libxi libxinerama libxss libxcursor libxpresent libxkbcommon wayland-protocols ttf-dejavu libsamplerate

sudo tee -a /etc/tmpfiles.d/10-looking-glass.conf << EOF
# Type Path               Mode UID  GID Age Argument

f /dev/shm/looking-glass 0660 $USER kvm -
EOF

cd ~/Downloads
git clone --recursive https://github.com/gnif/LookingGlass.git
cd LookingGlass
mkdir client/build
cd client/build
cmake ../
make
~/Downloads/LookingGlass/client/build/looking-glass-client


+ Edit script.sh and put the below commands [VGA is the main thing].

### Args to add [Only add these after udating,debloating,passing GPU to other side]
sudo -A echo ""

### Add
sudo qemu-system-x86_64 \
	-overcommit mem-lock=off -smp cores=4,threads=4,sockets=1 -m 11G -device virtio-balloon \
	-display none \
	-device VGA,vgamem_mb=64 \
	-device vfio-pci,host=01:00.0,multifunction=on \
	-device vfio-pci,host=01:00.1 \
	-spice port=5900,addr=127.0.0.1,disable-ticketing=on \
	-device ivshmem-plain,memdev=ivshmem,bus=pcie.0 \
	-object memory-backend-file,id=ivshmem,share=on,mem-path=/dev/shm/looking-glass,size=128M \
	-usb -device usb-host,vendorid=0x,productid=0x \

### Remove
# remote-viewer spice+unix:///run/user/1000/spice.sock &
# -spice unix=on,addr=/run/user/1000/spice.sock,disable-ticketing=on,image-compression=off,gl=on,rendernode=/dev/dri/by-path/pci-0000:05:00.0-render,seamless-migration=on \
# 	-device virtio-vga-gl \

+ Run the GPU Passthrough script.
+ Reboot main computer.
+ Install Looking glass bleeding edge.
+ Install NVCleaninstall with USB Driver with basic settings.
+ Reboot.
+ Now Plug the Fake HDMI Cable as the system us rebooting.

### Post Looking Glass

+ Check if resolution detected using Fake HDMI
+ Disable micrsoft basic software and reboot.
```

### FIREFOX

```bash

rm -rf $HOME/.mozilla
sudo rm -rf /usr/lib/firefox/distribution/policies.json

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
				"https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi",
				"https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi"
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
choice=$(printf "1.default-release : (ArkenFoxP) \n2.second : (ArkenFoxT)\n3.third : (BetterFOX)\n4.fourth : (Normal)"|bemenu -i -p "Choose Profile :" | awk -F":" '{print $1}'|awk -F"." '{print $2}'|xargs)
choice=$(echo -e "1.Default Profile[Brave]\n2.Temp Profile[Brave]\n3.Librewolf\n4.default-release[Firefox] : (ArkenFoxP) \n5.second[Firefox] : (ArkenFoxT)\n6.third[Firefox] : (BetterFOX)\n7.fourth[Firefox] : (Normal)" | bemenu -p "Choose Profile :" -i | awk -F"." '{print $1}')
if [[ "$choice" = "4" ]]; then
    libw "firefox:$(date +%s)" "default-release" "firefox"
fi
if [[ "$choice" = "5" ]]; then
    libw "firefox:$(date +%s)" "second" "firefox"
fi
if [[ "$choice" = "6" ]]; then
    libw "firefox:$(date +%s)" "third" "firefox"
fi
if [[ "$choice" = "7" ]]; then
    libw "firefox:$(date +%s)" "fourth" "firefox"
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

### Tesseract

```sh
sudo pacman -S --noconfirm tesseract-data-afr tesseract-data-amh tesseract-data-ara tesseract-data-asm tesseract-data-aze tesseract-data-aze_cyrl tesseract-data-bel tesseract-data-ben tesseract-data-bod tesseract-data-bos tesseract-data-bre tesseract-data-bul tesseract-data-cat tesseract-data-ceb tesseract-data-ces tesseract-data-chi_sim tesseract-data-chi_tra tesseract-data-chr tesseract-data-cos tesseract-data-cym tesseract-data-dan tesseract-data-dan_frak tesseract-data-deu tesseract-data-deu_frak tesseract-data-div tesseract-data-dzo tesseract-data-ell tesseract-data-eng tesseract-data-enm tesseract-data-epo tesseract-data-equ tesseract-data-est tesseract-data-eus tesseract-data-fao tesseract-data-fas tesseract-data-fil tesseract-data-fin tesseract-data-fra tesseract-data-frk tesseract-data-frm tesseract-data-fry tesseract-data-gla tesseract-data-gle tesseract-data-glg tesseract-data-grc tesseract-data-guj tesseract-data-hat tesseract-data-heb tesseract-data-hin tesseract-data-hrv tesseract-data-hun tesseract-data-hye tesseract-data-iku tesseract-data-ind tesseract-data-isl tesseract-data-ita tesseract-data-ita_old tesseract-data-jav tesseract-data-jpn tesseract-data-jpn_vert tesseract-data-kan tesseract-data-kat tesseract-data-kat_old tesseract-data-kaz tesseract-data-khm tesseract-data-kir tesseract-data-kmr tesseract-data-kor tesseract-data-kor_vert tesseract-data-lao tesseract-data-lat tesseract-data-lav tesseract-data-lit tesseract-data-ltz tesseract-data-mal tesseract-data-mar tesseract-data-mkd tesseract-data-mlt tesseract-data-mon tesseract-data-mri tesseract-data-msa tesseract-data-mya tesseract-data-nep tesseract-data-nld tesseract-data-nor tesseract-data-oci tesseract-data-ori tesseract-data-osd tesseract-data-pan tesseract-data-pol tesseract-data-por tesseract-data-pus tesseract-data-que tesseract-data-ron tesseract-data-rus tesseract-data-san tesseract-data-sin tesseract-data-slk tesseract-data-slk_frak tesseract-data-slv tesseract-data-snd tesseract-data-spa tesseract-data-spa_old tesseract-data-sqi tesseract-data-srp tesseract-data-srp_latn tesseract-data-sun tesseract-data-swa tesseract-data-swe tesseract-data-syr tesseract-data-tam tesseract-data-tat tesseract-data-tel tesseract-data-tgk tesseract-data-tgl tesseract-data-tha tesseract-data-tir tesseract-data-ton tesseract-data-tur tesseract-data-uig tesseract-data-ukr tesseract-data-urd tesseract-data-uzb tesseract-data-uzb_cyrl tesseract-data-vie tesseract-data-yid tesseract-data-yor
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

# Install pyenv , setup local GPT

echo ""
echo -----------------------------------------------------------------------------------------------------------------
echo "--------------Installing pyenv , Setting up local GPT , Installing base packages...------------------------------"
echo -----------------------------------------------------------------------------------------------------------------
echo ""

cd

### System Modules
install "cuda cudnn python-tensorflow-opt-cuda python-opt_einsum numactl" "pac"
install "python-opencv" "pac"

### Install Pyenv

# Download pyenv
curl https://pyenv.run | bash
source $HOME/.config/fish/config.fish

# Create a Virtual env
set venvname (echo "play")
pyenv virtualenv "$venvname"
set venvLocation (echo "$HOME/.pyenv/versions/$venvname/bin/activate.fish")
source "$venvLocation"

### Setup local GPT

# Clone Repo
cd
git clone https://github.com/h2oai/h2ogpt
cd h2ogpt
pip install -r requirements.txt
pip install -r reqs_optional/requirements_optional_langchain.txt
pip install -r reqs_optional/requirements_optional_gpt4all.txt

# Download LLM Models
aria2c -j 16 -x 16 -s 16 -k 1M "https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGML/resolve/main/llama-2-7b-chat.ggmlv3.q8_0.bin" -o "llama-2-7b-chat.ggmlv3.q8_0.bin"
aria2c -j 16 -x 16 -s 16 -k 1M "https://huggingface.co/TheBloke/CodeUp-Llama-2-13B-Chat-HF-GGML/resolve/main/codeup-llama-2-13b-chat-hf.ggmlv3.q4_K_S.bin" -o "llama-2-13b-chat-hf.ggmlv3.q4_K_S.bin"

# Create a script
echo 'python generate.py --base_model="llama" --model-path=llama-2-13b-chat-hf.ggmlv3.q4_K_S.bin --prompt_type=llama2 --hf_embedding_model=sentence-transformers/all-MiniLM-L6-v2 --langchain_mode=UserData --user_path=user_path --llamacpp_dict="{'n_gpu_layers':25,'n_batch':128,'n_threads':6}" --load_8bit=True' > run.sh
chmod +x run.sh

### Install Base Packages for this env

for i in (seq 2)
    pip install torch torchvision torchaudio
    pip install opencv-contrib-python
    pip install wrapt gast astunparse opt_einsum
    pip uninstall tensorflow
end

for i in (seq 3)
    pip install jupyter pandas matplotlib numpy scikit-learn openpyxl xlrd
    pip install notebook==6.4.12
    pip install pygments tqdm lxml
    pip install notebook-as-pdf jupyter_contrib_nbextensions jupyter_nbextensions_configurator nbconvert
    jupyter contrib nbextension install --user
    jupyter nbextensions_configurator enable --user
    pyppeteer-install
end

### Copy and Download required scripts

# Copy tensorflow
set destinationLocation (echo "$HOME/.pyenv/versions/$venvname/lib/python3.11/site-packages/")
sudo cp -r /usr/lib/python3.11/site-packages/tensorflow "$destinationLocation"

# Copy libiomp5.so
set libiomp5Location (fd . /usr/lib/python3.11/site-packages | grep "solib" | head -1)
sudo cp -r "$libiomp5Location" "$destinationLocation"

### Cleanup

deactivate
rm -rf blog/ ci/ docs .git papers/ docker-compose.yml Dockerfile h2o-logo.svg LICENSE README.md
cd ..
mv h2ogpt llm
cd
```

# ENV

```fish
# Nvidia CUDA
set venvname (echo "play")
set cudnnLocation (echo "$HOME/.pyenv/versions/$venvname/lib/python3.11/site-packages/nvidia/cudnn")
if test -d "$cudnnLocation"
    set CUDNN_PATH $cudnnLocation $CUDNN_PATH
    set LD_LIBRARY_PATH /opt/cuda/lib64 $LD_LIBRARY_PATH
    set PATH /opt/cuda/bin/ $PATH
end

### Pyenv

# Function to activate virtual environment
function acv
    set pyenvLocation (echo "$HOME/.pyenv")
    mkdir -p "$pyenvLocation/versions/systempython"

    if test -n "$VIRTUAL_ENV"
        echo -e "You are inside a Python virtual environment. It can create confusion.\nFirst Deactive the virtual env and run this command again"
    else
        if test -d "$pyenvLocation"
            set getChoice (fd . $HOME/.pyenv/versions --type=d --max-depth=1 | rev | awk -F"/" '{print $2}'| rev | fzf)
            if [ $getChoice = systempython ]
                echo "Switch to systems python!"
                pyenv local --unset
                python --version
            else
                if test -z "$getChoice"
                    true
                else
                    set isPython (echo "$getChoice" | grep -E '^([0-9]+)\.[0-9]+(\.[0-9]+)?$')
                    if test -z "$isPython"
                        set venvLocation (echo "$HOME/.pyenv/versions/$getChoice/bin/activate.fish")
                        source "$venvLocation"
                        echo "Swtiched to virtual environment $getChoice!"
                    else
                        pyenv local --unset
                        pyenv local "$getChoice"
                        echo "Python Interpreter switched!"
                        python --version
                    end
                end
            end
        end
    end
end

# Source Pyenv
set pyenvLocation (echo "$HOME/.pyenv")
if test -d "$pyenvLocation"
    set -Ux PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    pyenv init - | source
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

# Artix spice vdagent

```sh
sudo pacman -S --noconfirm spice-vdagent-openrc
sudo rc-update add spice-vdagent
sudo rc-service spice-vdagent start
```

# After Install

```fish
sudo echo ""
curl "https://ollama.ai/install.sh" | sh
nohup ollama serve &
rm nohup.out
nohup ollama serve &
rm nohup.out
ollama pull mistral:latest
ollama pull zephyr:7b-beta
ollama pull gemma:7b
dst
docker run -d --network=host -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 --name open-webui --restart always ghcr.io/open-webui/open-webui:main
dsp
ps aux | grep -i 'ollama' | awk '{print $2}' | xargs -ro kill -9

cleanup
yay -S --noconfirm mongodb-compass

sudo rc-service nftables save
sudo rc-update add nftables
sudo rc-service nftables restart
```
