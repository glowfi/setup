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
sudo pacman -S --noconfirm bluez bluez-utils blueman
yay -S --noconfirm ttf-fantasque-nerd ttf-ms-fonts ttf-vista-fonts
sudo pacman -S --noconfirm android-tools scrcpy

### PACKAGES
sudo pacman -S --noconfirm kdeconnect kcolorchooser
sudo pacman -S --noconfirm tesseract community/tesseract-data-afr community/tesseract-data-amh community/tesseract-data-ara community/tesseract-data-asm community/tesseract-data-aze community/tesseract-data-aze_cyrl community/tesseract-data-bel community/tesseract-data-ben community/tesseract-data-bod community/tesseract-data-bos community/tesseract-data-bre community/tesseract-data-bul community/tesseract-data-cat community/tesseract-data-ceb community/tesseract-data-ces community/tesseract-data-chi_sim community/tesseract-data-chi_tra community/tesseract-data-chr community/tesseract-data-cos community/tesseract-data-cym community/tesseract-data-dan community/tesseract-data-dan_frak community/tesseract-data-deu community/tesseract-data-deu_frak community/tesseract-data-div community/tesseract-data-dzo community/tesseract-data-ell community/tesseract-data-eng community/tesseract-data-enm community/tesseract-data-epo community/tesseract-data-equ community/tesseract-data-est community/tesseract-data-eus community/tesseract-data-fao community/tesseract-data-fas community/tesseract-data-fil community/tesseract-data-fin community/tesseract-data-fra community/tesseract-data-frk community/tesseract-data-frm community/tesseract-data-fry community/tesseract-data-gla community/tesseract-data-gle community/tesseract-data-glg community/tesseract-data-grc community/tesseract-data-guj community/tesseract-data-hat community/tesseract-data-heb community/tesseract-data-hin community/tesseract-data-hrv community/tesseract-data-hun community/tesseract-data-hye community/tesseract-data-iku community/tesseract-data-ind community/tesseract-data-isl community/tesseract-data-ita community/tesseract-data-ita_old community/tesseract-data-jav community/tesseract-data-jpn community/tesseract-data-jpn_vert community/tesseract-data-kan community/tesseract-data-kat community/tesseract-data-kat_old community/tesseract-data-kaz community/tesseract-data-khm community/tesseract-data-kir community/tesseract-data-kmr community/tesseract-data-kor community/tesseract-data-kor_vert community/tesseract-data-lao community/tesseract-data-lat community/tesseract-data-lav community/tesseract-data-lit community/tesseract-data-ltz community/tesseract-data-mal community/tesseract-data-mar community/tesseract-data-mkd community/tesseract-data-mlt community/tesseract-data-mon community/tesseract-data-mri community/tesseract-data-msa community/tesseract-data-mya community/tesseract-data-nep community/tesseract-data-nld community/tesseract-data-nor community/tesseract-data-oci community/tesseract-data-ori community/tesseract-data-osd community/tesseract-data-pan community/tesseract-data-pol community/tesseract-data-por community/tesseract-data-pus community/tesseract-data-que community/tesseract-data-ron community/tesseract-data-rus community/tesseract-data-san community/tesseract-data-sin community/tesseract-data-slk community/tesseract-data-slk_frak community/tesseract-data-slv community/tesseract-data-snd community/tesseract-data-spa community/tesseract-data-spa_old community/tesseract-data-sqi community/tesseract-data-srp community/tesseract-data-srp_latn community/tesseract-data-sun community/tesseract-data-swa community/tesseract-data-swe community/tesseract-data-syr community/tesseract-data-tam community/tesseract-data-tat community/tesseract-data-tel community/tesseract-data-tgk community/tesseract-data-tgl community/tesseract-data-tha community/tesseract-data-tir community/tesseract-data-ton community/tesseract-data-tur community/tesseract-data-uig community/tesseract-data-ukr community/tesseract-data-urd community/tesseract-data-uzb community/tesseract-data-uzb_cyrl community/tesseract-data-vie community/tesseract-data-yid community/tesseract-data-yor
yay -S --noconfirm brave-bin

### IMAGE
sudo pacman -Syyy --noconfirm gimp imagemagick ffmpegthumbnailer
yay -S --noconfirm gimp-plugin-registry

### VIDEO
sudo pacman -Syyy --noconfirm kdenlive ffmpeg yt-dlp mujs
yay -S --noconfirm mpv-git

### AUDIO
sudo pacman -Syyy --noconfirm songrec mediainfo

sudo pacman -Syyy --noconfirm easyeffects lsp-plugins
wget https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh
chmod +x ./install.sh
echo | ./install.sh
rm install.sh

### PERIPHERAL
yay -S --noconfirm openrazer-meta polychromatic
sudo gpasswd -a $USER plugdev

### EXTRAS
yay -S --noconfirm onlyoffice-bin tectonic
yay -S --noconfirm pandoc-bin

### TERMINAL TOMFOOLERY
sudo pacman -S --noconfirm fortune-mod figlet lolcat cmatrix asciiquarium cowsay sl

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

# ENABLE ZRAM

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Enabling ZRAM...------------------------------------------"
echo "------------------------------------------------------------------------"
echo ""
yay -S --noconfirm zramd
sudo sed -i '2s/.*/ALGORITHM=zstd/' /etc/default/zramd
sudo sed -i '8s/.*/MAX_SIZE=32768/' /etc/default/zramd
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
