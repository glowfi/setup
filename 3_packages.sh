#!/bin/bash

# READ FILES
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CONFIG_FILE=/home/$USERNAME/setup/setup.conf

# Read Username
USERNAME=$(sed -n '6p' <"$CONFIG_FILE")

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
sudo pacman -Syy

## Xorg packages
sudo pacman -S --noconfirm xorg-server

# AUR HELPER

echo ""
echo "----------------------------------------------------------------"
echo "--------------Installing AUR helper...--------------------------"
echo "----------------------------------------------------------------"
echo ""

git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin/
makepkg -si --noconfirm
cd /home/$USERNAME
rm -rf yay-bin

# PACKAGES

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing required packages...---------------------------"
echo "------------------------------------------------------------------------"
echo ""

### CORE
sudo pacman -S --noconfirm zip unzip unrar p7zip lzop
sudo pacman -S --noconfirm fish kitty imagemagick ttf-fantasque-sans-mono man-db noto-fonts-emoji noto-fonts
sudo pacman -S --noconfirm alsa-utils alsa-plugins pipewire pipewire-alsa pipewire-pulse pipewire-jack
# yay -S --noconfirm zramd nerd-fonts-fantasque-sans-mono
yay -S --noconfirm nerd-fonts-fantasque-sans-mono

### CDX
sudo pacman -S --noconfirm postgresql redis python-pip gitui github-cli
yay -S --noconfirm mongodb-bin

### PACK
sudo pacman -S --noconfirm kdeconnect
yay -S --noconfirm brave-bin onlyoffice-bin
yay -S --noconfirm sc-im libxlsxwriter pandoc-bin

### TERMINAL TOMFOOLERY
sudo pacman -S --noconfirm fortune-mod figlet lolcat cmatrix asciiquarium cowsay ponysay
yay -S --noconfirm toilet toilet-fonts
git clone https://github.com/xero/figlet-fonts
sudo cp -r figlet-fonts/* /usr/share/figlet/fonts
rm -rf figlet-fonts
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

### EDIT
sudo pacman -S --noconfirm gimp kdenlive ffmpeg ffmpegthumbnailer youtube-dl mpv songrec ardour mediainfo stellarium
yay -S --noconfirm gimp-plugin-registry

# # ENABLE ZRAM

# echo ""
# echo "------------------------------------------------------------------------"
# echo "--------------Enabling ZRAM...------------------------------------------"
# echo "------------------------------------------------------------------------"
# echo ""

# sudo sed -i '8s/.*/MAX_SIZE=724/' /etc/default/zramd
# sudo systemctl enable --now zramd

# ADD FEATURES TO sudoers

echo ""
echo "-------------------------------------------------------------------------"
echo "--------------Adding insults on wrong password...------------------------"
echo "-------------------------------------------------------------------------"
echo ""

sudo sed -i '71s/.*/Defaults insults/' /etc/sudoers
echo "Done adding insults!"

# SETUP APPARMOR

# echo ""
# echo "------------------------------------------------------------------------"
# echo "--------------Enabling APPARMOR...--------------------------------------"
# echo "------------------------------------------------------------------------"
# echo ""

# sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet lsm=landlock,lockdown,yama,apparmor,bpf"/' /etc/default/grub
# sudo grub-mkconfig -o /boot/grub/grub.cfg
# sudo pacman -S --noconfirm apparmor
# sudo systemctl enable --now apparmor.service

echo ""
echo "------------------------------------------------------------------------"
echo "--------------COPYING SETTINGS...---------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# COPY FISH SHELL SETTINGS

fish -c "exit"
cp -r /home/$USERNAME/setup/configs/config.fish /home/$USERNAME/.config/fish/

# COPY BASHRC
cp -r /home/$USERNAME/setup/configs/.bashrc /home/$USERNAME

# INSTALL AND COPY NNN FM SETTINGS

sudo pacman -S --noconfirm trash-cli
git clone https://github.com/jarun/nnn
cd nnn
sudo make O_NERD=1 install
cd ..
rm -rf nnn

mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
sed -i '204 a                      --theme=gruvbox-dark --paging=never --style="$BAT_STYLE" "$@" &' /home/$USERNAME/.config/nnn/plugins/preview-tui
sed -i '204d' /home/$USERNAME/.config/nnn/plugins/preview-tui

# COPY KITTY SETTINGS

cp -r /home/$USERNAME/setup/configs/kitty /home/$USERNAME/.config/

# CHANGE DEFAULT SHELL

echo ""
echo "------------------------------------------------------------------------------"
echo "--------------CHANGING DEFAULT SHELL...---------------------------------------"
echo "------------------------------------------------------------------------------"
echo ""
sudo usermod --shell /bin/fish $USERNAME
echo "Changed default shell!"
