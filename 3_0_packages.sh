#!/bin/bash

# Source Helper
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/helper.sh"

# CACHE PASSWORD
sudo sed -i '71 a Defaults        timestamp_timeout=30000' /etc/sudoers

# SYNCHRONIZING

echo ""
echo "--------------------------------------------------------------"
echo "--------------Refreshing mirrorlist...------------------------"
echo "--------------------------------------------------------------"
echo ""

sudo timedatectl set-ntp true
sudo hwclock --systohc
sudo reflector --verbose -c DE --latest 5 --age 2 --fastest 5 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
install "archlinux-keyring" "pac"
sudo pacman -Syy

# AUR HELPER

echo ""
echo "----------------------------------------------------------------"
echo "--------------Installing AUR helper...--------------------------"
echo "----------------------------------------------------------------"
echo ""

git clone https://aur.archlinux.org/yay-bin.git
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

## Xorg packages
install "xorg-server" "pac"

### CORE (Main)
install "zip unzip unrar p7zip lzop" "pac"
install "ouch" "pac"

install "man-db" "pac"
install "fish kitty" "pac"

### CORE (Fonts)
install "ttf-fantasque-sans-mono noto-fonts-emoji noto-fonts" "pac"
install "ttf-fantasque-nerd ttf-ms-fonts ttf-vista-fonts" "yay"

### CORE (AUDIO)
install "alsa-utils alsa-plugins pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber" "pac"
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

### CORE (PERIPHERALS)
install "openrazer-meta polychromatic" "yay"
sudo gpasswd -a $USER plugdev

### CORE (EXTRAS)
install "android-tools scrcpy" "pac"
install "kdeconnect kcolorchooser" "pac"
install "mediainfo perl-image-exiftool" "pac"

### CORE (Use old package version)
mkdir test
cd test
wget "https://archive.archlinux.org/packages/t/ttf-fantasque-nerd/ttf-fantasque-nerd-2.3.3-3-any.pkg.tar.zst"
sudo pacman -U --noconfirm ./ttf-fantasque-nerd-2.3.3-3-any.pkg.tar.zst
wget "https://archive.archlinux.org/packages/i/iptables-nft/iptables-nft-1%3A1.8.8-3-x86_64.pkg.tar.zst"
yes | sudo pacman -U ./iptables-nft-1:1.8.8-3-x86_64.pkg.tar.zst
sudo sed -i "25s/.*/IgnorePkg = ttf-fantasque-nerd iptables-nft/" /etc/pacman.conf
cd ..
rm -rf test

# ======================================================= Can Be Deleted for minimal install =======================================================

#### ADDITIONAL PACKAGES

### IMAGE
install "kolourpaint" "pac"
install "gimp" "pac"
install "gimp-plugin-registry" "yay"
rm -rf $HOME/.config/GIMP/2.10
mkdir -p $HOME/.config/GIMP/2.10
cd $HOME/.config/GIMP/2.10
git clone https://github.com/Diolinux/PhotoGIMP
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
install "pandoc-bin tectonic" "yay"

# ======================================================= END ======================================================================================

### TERMINAL TOMFOOLERY
install "fortune-mod figlet lolcat cmatrix asciiquarium cowsay sl" "pac"

git clone https://github.com/pipeseroni/pipes.sh
cd pipes.sh
sudo make clean install
cd ..
rm -rf pipes.sh

git clone https://github.com/xorg62/tty-clock
cd tty-clock
sudo make clean install
cd ..
rm -rf tty-clock

# ADD FEATURES TO sudoers

echo ""
echo "-------------------------------------------------------------------------"
echo "--------------Adding insults on wrong password...------------------------"
echo "-------------------------------------------------------------------------"
echo ""

sudo sed -i '71s/.*/Defaults insults/' /etc/sudoers
echo "Done adding insults!"

# THEMING GRUB

echo ""
echo "------------------------------------------------------------------------"
echo "--------------THEMING GRUB...-------------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

git clone --depth=1 https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes/
rm backgrounds/1080p/background-tela.jpg
cp -r $HOME/setup/scripts/background-tela.jpg backgrounds/1080p/
sudo ./install.sh -b -t tela
cd ..
rm -rf grub2-themes

echo ""
echo "------------------------------------------------------------------------"
echo "--------------COPYING SETTINGS...---------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# COPY FISH SHELL SETTINGS

fish -c "exit"
cp -r $HOME/setup/configs/config.fish $HOME/.config/fish/

# COPY BASH inputrc VIM TMUX TO HOME

install "tmux" "pac"
cp -r $HOME/setup/configs/.bashrc $HOME
cp -r $HOME/setup/configs/.inputrc $HOME
cp -r $HOME/setup/configs/.vimrc $HOME
cp -r $HOME/setup/configs/.tmux.conf $HOME
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
rm -rf ble.sh

# COPY BASH inputrc VIM TMUX TO ROOT

sudo cp $HOME/.bashrc /root/
sudo cp $HOME/.inputrc /root/
sudo cp $HOME/.vimrc /root/
sudo cp $HOME/.tmux.conf /root/
sudo su -c "git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git;make -C ble.sh install PREFIX=~/.local;rm -rf ble.sh"

# INSTALL AND COPY NNN FM SETTINGS

sudo pacman -S --noconfirm trash-cli tree
git clone https://github.com/jarun/nnn
cd nnn
sudo make O_NERD=1 install
cd ..
rm -rf nnn

mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
cd
cp -r $HOME/setup/scripts/preview-tui $HOME/.config/nnn/plugins

# COPY KITTY SETTINGS

cp -r $HOME/setup/configs/kitty $HOME/.config/

# COPY ICONS

cp -r $HOME/setup/configs/img $HOME/.local/share/

# CHANGE DEFAULT SHELL

echo ""
echo "------------------------------------------------------------------------------"
echo "--------------CHANGING DEFAULT SHELL...---------------------------------------"
echo "------------------------------------------------------------------------------"
echo ""
sudo usermod --shell /bin/fish "$USER"
echo "Changed default shell!"
