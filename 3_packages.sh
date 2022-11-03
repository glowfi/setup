#!/bin/bash

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
sudo pacman -S --noconfirm archlinux-keyring
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
cd ~
rm -rf yay-bin

# PACKAGES

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing required packages...---------------------------"
echo "------------------------------------------------------------------------"
echo ""

## Xorg packages
sudo pacman -S --noconfirm xorg-server

### CORE
sudo pacman -S --noconfirm zip unzip unrar p7zip lzop
sudo pacman -S --noconfirm fish kitty ttf-fantasque-sans-mono man-db noto-fonts-emoji noto-fonts
sudo pacman -S --noconfirm alsa-utils alsa-plugins pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber
sudo pacman -S --noconfirm bluez bluez-utils bluedevil
yay -S --noconfirm zramd nerd-fonts-fantasque-sans-mono ttf-ms-fonts ttf-vista-fonts

### PACKAGES
sudo pacman -S --noconfirm kdeconnect
sudo pacman -S --noconfirm tesseract tesseract-data-eng
yay -S --noconfirm brave-bin

### IMAGE
sudo pacman -Syyy --noconfirm gimp imagemagick ffmpegthumbnailer
yay -S --noconfirm gimp-plugin-registry

### VIDEO
sudo pacman -Syyy --noconfirm kdenlive ffmpeg yt-dlp mpv

### AUDIO
sudo pacman -Syyy --noconfirm songrec mediainfo

### PERIPHERAL
yay -S --noconfirm openrazer-meta polychromatic
sudo gpasswd -a $USER plugdev

### EXTRAS
yay -S --noconfirm onlyoffice-bin tectonic
yay -S --noconfirm sc-im libxlsxwriter pandoc-bin

### TERMINAL TOMFOOLERY
sudo pacman -S --noconfirm fortune-mod figlet lolcat cmatrix asciiquarium cowsay sl

# ENABLE ZRAM

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Enabling ZRAM...------------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

sudo sed -i '2s/.*/ALGORITHM=zstd/' /etc/default/zramd
sudo sed -i '8s/.*/MAX_SIZE=8192/' /etc/default/zramd
sudo systemctl enable --now zramd

# ADD FEATURES TO sudoers

echo ""
echo "-------------------------------------------------------------------------"
echo "--------------Adding insults on wrong password...------------------------"
echo "-------------------------------------------------------------------------"
echo ""

sudo sed -i '71s/.*/Defaults insults/' /etc/sudoers
echo "Done adding insults!"

# SETUP APPARMOR

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Enabling APPARMOR...--------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 lsm=landlock,lockdown,yama,apparmor,bpf"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo pacman -S --noconfirm apparmor
sudo systemctl enable --now apparmor.service

# THEMING GRUB

echo ""
echo "------------------------------------------------------------------------"
echo "--------------THEMING GRUB...-------------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

git clone --depth=1 https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes/
rm backgrounds/1080p/background-tela.jpg
cp -r ~/setup/scripts/background-tela.jpg backgrounds/1080p/
sudo ./install.sh -b -t tela
cd ..
rm -rf grub2-themes

# SECURITY FEATURES

touch ~/blacklist.conf
echo "# Disable webcam
blacklist uvcvideo" >>~/blacklist.conf
sudo cp -r ~/blacklist.conf /etc/modprobe.d/
rm ~/blacklist.conf

echo ""
echo "------------------------------------------------------------------------"
echo "--------------COPYING SETTINGS...---------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# COPY FISH SHELL SETTINGS

fish -c "exit"
cp -r ~/setup/configs/config.fish ~/.config/fish/

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
cp -r ~/setup/scripts/preview-tui ~/.config/nnn/plugins

git clone https://github.com/mwh/dragon
cd dragon
make clean install
cd ..
rm -rf dragon

# COPY KITTY SETTINGS

cp -r ~/setup/configs/kitty ~/.config/

# CHANGE DEFAULT SHELL

echo ""
echo "------------------------------------------------------------------------------"
echo "--------------CHANGING DEFAULT SHELL...---------------------------------------"
echo "------------------------------------------------------------------------------"
echo ""
sudo usermod --shell /bin/fish $1
echo "Changed default shell!"
