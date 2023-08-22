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

### CORE
install "zip unzip unrar p7zip lzop" "pac"
install "fish kitty ttf-fantasque-sans-mono man-db noto-fonts-emoji noto-fonts" "pac"
install "alsa-utils alsa-plugins pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber" "pac"
install "bluez bluez-utils" "pac"
install "net-tools" "pac"
install "ttf-fantasque-nerd ttf-ms-fonts ttf-vista-fonts" "yay"
mkdir test
cd test
wget "https://archive.archlinux.org/packages/t/ttf-fantasque-nerd/ttf-fantasque-nerd-2.3.3-3-any.pkg.tar.zst"
sudo pacman -U --noconfirm ./ttf-fantasque-nerd-2.3.3-3-any.pkg.tar.zst
wget "https://archive.archlinux.org/packages/i/iptables-nft/iptables-nft-1%3A1.8.8-3-x86_64.pkg.tar.zst"
yes | sudo pacman -U ./iptables-nft-1:1.8.8-3-x86_64.pkg.tar.zst
sudo sed -i "25s/.*/IgnorePkg = ttf-fantasque-nerd iptables-nft/" /etc/pacman.conf
cd ..
rm -rf test
install "android-tools scrcpy" "pac"

### PACKAGES
install "kdeconnect kcolorchooser" "pac"
install "tesseract tesseract-data-afr tesseract-data-amh tesseract-data-ara tesseract-data-asm tesseract-data-aze tesseract-data-aze_cyrl tesseract-data-bel tesseract-data-ben tesseract-data-bod tesseract-data-bos tesseract-data-bre tesseract-data-bul tesseract-data-cat tesseract-data-ceb tesseract-data-ces tesseract-data-chi_sim tesseract-data-chi_tra tesseract-data-chr tesseract-data-cos tesseract-data-cym tesseract-data-dan tesseract-data-dan_frak tesseract-data-deu tesseract-data-deu_frak tesseract-data-div tesseract-data-dzo tesseract-data-ell tesseract-data-eng tesseract-data-enm tesseract-data-epo tesseract-data-equ tesseract-data-est tesseract-data-eus tesseract-data-fao tesseract-data-fas tesseract-data-fil tesseract-data-fin tesseract-data-fra tesseract-data-frk tesseract-data-frm tesseract-data-fry tesseract-data-gla tesseract-data-gle tesseract-data-glg tesseract-data-grc tesseract-data-guj tesseract-data-hat tesseract-data-heb tesseract-data-hin tesseract-data-hrv tesseract-data-hun tesseract-data-hye tesseract-data-iku tesseract-data-ind tesseract-data-isl tesseract-data-ita tesseract-data-ita_old tesseract-data-jav tesseract-data-jpn tesseract-data-jpn_vert tesseract-data-kan tesseract-data-kat tesseract-data-kat_old tesseract-data-kaz tesseract-data-khm tesseract-data-kir tesseract-data-kmr tesseract-data-kor tesseract-data-kor_vert tesseract-data-lao tesseract-data-lat tesseract-data-lav tesseract-data-lit tesseract-data-ltz tesseract-data-mal tesseract-data-mar tesseract-data-mkd tesseract-data-mlt tesseract-data-mon tesseract-data-mri tesseract-data-msa tesseract-data-mya tesseract-data-nep tesseract-data-nld tesseract-data-nor tesseract-data-oci tesseract-data-ori tesseract-data-osd tesseract-data-pan tesseract-data-pol tesseract-data-por tesseract-data-pus tesseract-data-que tesseract-data-ron tesseract-data-rus tesseract-data-san tesseract-data-sin tesseract-data-slk tesseract-data-slk_frak tesseract-data-slv tesseract-data-snd tesseract-data-spa tesseract-data-spa_old tesseract-data-sqi tesseract-data-srp tesseract-data-srp_latn tesseract-data-sun tesseract-data-swa tesseract-data-swe tesseract-data-syr tesseract-data-tam tesseract-data-tat tesseract-data-tel tesseract-data-tgk tesseract-data-tgl tesseract-data-tha tesseract-data-tir tesseract-data-ton tesseract-data-tur tesseract-data-uig tesseract-data-ukr tesseract-data-urd tesseract-data-uzb tesseract-data-uzb_cyrl tesseract-data-vie tesseract-data-yid tesseract-data-yor" "pac"
install "ouch" "pac"
install "gource" "pac"

### IMAGE
install "imagemagick ffmpegthumbnailer" "pac"
install "gimp kolourpaint" "pac"
install "gimp-plugin-registry" "yay"
rm -rf $HOME/.config/GIMP/2.10
mkdir -p $HOME/.config/GIMP/2.10
cd $HOME/.config/GIMP/2.10
git clone https://github.com/Diolinux/PhotoGIMP
mv ./PhotoGIMP/.var/app/org.gimp.GIMP/config/GIMP/2.10/* .
rm -rf PhotoGIMP filters plug-ins splashes
cd

### VIDEO
install "kdenlive ffmpeg yt-dlp mujs" "pac"
install "mpv" "pac"

### AUDIO
install "songrec" "pac"

install "easyeffects lsp-plugins" "pac"
mkdir -p $HOME/.config/easyeffects/ $HOME/.config/easyeffects/output
wget https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh
chmod +x ./install.sh
echo | ./install.sh
rm install.sh

### PERIPHERAL
install "openrazer-meta polychromatic" "yay"
sudo gpasswd -a $USER plugdev

### EXTRAS
install "mediainfo perl-image-exiftool" "pac"
install "onlyoffice-bin tectonic" "yay"
install "pandoc-bin" "yay"

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
