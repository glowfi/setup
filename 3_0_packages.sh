#!/usr/bin/env bash

# Source Helper
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
DETECT_INIT_SCRIPT="$SCRIPT_DIR/detectInit.sh"
source "$SCRIPT_DIR/helper.sh"

# Git clone helper
klone() {
	for ((i = 0; i < 10; i++)); do
		git clone "$1" && break
	done

}

# Get Init Type
initType=$(bash "${DETECT_INIT_SCRIPT}")

# CACHE PASSWORD
sudo sed -i '71 a Defaults        timestamp_timeout=30000' /etc/sudoers

# SYNCHRONIZING

echo ""
echo "--------------------------------------------------------------"
echo "--------------Refreshing mirrorlist...------------------------"
echo "--------------------------------------------------------------"
echo ""

if [[ "$initType" != "systemD" ]]; then
	sudo hwclock --systohc
	sudo reflector --verbose -c DE --latest 5 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist-arch
	sudo pacman -Syy
else
	sudo timedatectl set-ntp true
	sudo hwclock --systohc
	sudo reflector --verbose -c DE --latest 5 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
	install "archlinux-keyring" "pac"
	sudo pacman -Syy
fi

# Systemctl shim

if [[ "$initType" != "systemD" ]]; then
	klone "https://github.com/oz123/systemctl-shim"
	cd systemctl-shim
	sudo make install
	cd ..
	rm -rf systemctl-shim
fi

# AUR HELPER

echo ""
echo "----------------------------------------------------------------"
echo "--------------Installing AUR helper...--------------------------"
echo "----------------------------------------------------------------"
echo ""

klone "https://aur.archlinux.org/yay-bin.git"
cd yay-bin/
makepkg -si --noconfirm
cd $HOME
rm -rf yay-bin

# PACKAGES

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing required packages...---------------------------"
echo "------------------------------------------------------------------------"
echo ""

### CORE (Main)
install "zip unzip unrar p7zip lzop" "pac"
install "ouch" "pac"

install "man-db" "pac"
install "fish kitty" "pac"
install "jq" "pac"
install "aria2" "pac"

if [[ "$initType" != "systemD" ]]; then
	install "rate-mirrors-bin" "yay"
fi

### CORE (Fonts)
install "ttf-fantasque-sans-mono noto-fonts-emoji noto-fonts ttf-joypixels" "pac"
install "ttf-fantasque-nerd ttf-ms-fonts ttf-vista-fonts" "yay"

### CORE (AUDIO)
if [[ "$initType" != "systemD" ]]; then
	install "alsa-utils alsa-plugins pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber" "pac"
	install "artix-pipewire-loader" "yay"
	artix-pipewire-loader &
else
	install "alsa-utils alsa-plugins pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber" "pac"
	systemctl --user enable pipewire.service pipewire.socket wireplumber.service pipewire-pulse.service pipewire-pulse.socket pipewire-session-manager.service
fi
install "bluez bluez-utils" "pac"
install "songrec" "pac"
install "easyeffects lsp-plugins" "pac"
mkdir -p $HOME/.config/easyeffects/ $HOME/.config/easyeffects/output
wget https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh
chmod +x ./install.sh
echo | ./install.sh
rm install.sh

### CORE (VIDEO)
install "ffmpeg yt-dlp" "pac"
install "mujs" "pac"
install "mpv" "pac"

### CORE (IMAGE)
install "imagemagick ffmpegthumbnailer" "pac"

### CORE (EXTRAS)
install "android-tools scrcpy" "pac"
install "localsend-bin" "yay"
install "gpick" "pac"
install "mediainfo perl-image-exiftool" "pac"
install "inotify-tools libnotify" "pac"

# ======================================================= Can Be Deleted for minimal install =======================================================

#### ADDITIONAL PACKAGES

### IMAGE
install "python2-bin" "yay"
install "gimp" "pac"
install "gimp-plugin-registry" "yay"
rm -rf $HOME/.config/GIMP/2.10
mkdir -p $HOME/.config/GIMP/2.10
cd $HOME/.config/GIMP/2.10
klone "https://github.com/Diolinux/PhotoGIMP"
mv ./PhotoGIMP/.var/app/org.gimp.GIMP/config/GIMP/2.10/* .
rm -rf PhotoGIMP filters plug-ins splashes
cd

### AUDIO
# None

### VIDEO
install "kdenlive" "pac"

### PERIPHERALS
# None

### EXTRAS
install "onlyoffice-bin" "yay"
install "tectonic" "pac"

# ======================================================= END ======================================================================================

### TERMINAL TOMFOOLERY
install "fortune-mod lolcat cmatrix asciiquarium cowsay" "pac"
for i in {1..5}; do yes | sudo pacman -S sl && break || sleep 1; done

install "figlet" "pac"
install "toilet toilet-fonts" "yay"
klone "https://github.com/xero/figlet-fonts"
sudo cp -r figlet-fonts/* /usr/share/figlet/fonts
rm -rf figlet-fonts

klone "https://github.com/pipeseroni/pipes.sh"
cd pipes.sh
sudo make clean install
cd ..
rm -rf pipes.sh

# ===================== XORG Dependent ===================================
klone "https://github.com/xorg62/tty-clock"
cd tty-clock
sudo make clean install
cd ..
rm -rf tty-clock
# ===================== END Dependent ====================================

echo ""
echo "------------------------------------------------------------------------"
echo "--------------COPYING SETTINGS...---------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# COPY FISH SHELL SETTINGS

fish -c "exit"
cp -r $HOME/setup/configs/config.fish $HOME/.config/fish/

# COPY bash inputrc vimrc SETTINGS TO HOME

cp -r $HOME/setup/configs/.bashrc $HOME
cp -r $HOME/setup/configs/.inputrc $HOME
cp -r $HOME/setup/configs/.vimrc $HOME

# Installing ble.sh for completion like fish in bash

git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
rm -rf ble.sh

# COPY bash inputrc vimrc SETTINGS TO ROOT

sudo cp $HOME/.bashrc /root/
sudo cp $HOME/.inputrc /root/
sudo cp $HOME/.vimrc /root/
sudo su -c "git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git;make -C ble.sh install PREFIX=~/.local;rm -rf ble.sh"

# INSTALL AND COPY NNN FM SETTINGS

sudo pacman -S --noconfirm trash-cli tree
klone "https://github.com/jarun/nnn"
cd nnn
sudo make O_NERD=1 install
cd ..
rm -rf nnn

mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
cd
cp -r $HOME/setup/scripts/misc/preview-tui $HOME/.config/nnn/plugins

# COPY KITTY SETTINGS

cp -r $HOME/setup/configs/kitty $HOME/.config/

# CHANGE DEFAULT SHELL

echo ""
echo "------------------------------------------------------------------------------"
echo "--------------CHANGING DEFAULT SHELL...---------------------------------------"
echo "------------------------------------------------------------------------------"
echo ""
sudo usermod --shell /bin/fish "$USER"
echo "Changed default shell!"
