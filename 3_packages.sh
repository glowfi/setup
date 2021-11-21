#!/bin/sh

echo ""
echo "--------------------------------------------------------------"
echo "--------------Refreshing mirrorlist...------------------------"
echo "--------------------------------------------------------------"
echo ""

# SYNCHRONIZING

sudo timedatectl set-ntp true
sudo hwclock --systohc
sudo reflector --verbose --protocol https -a 48 -c DE -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Syy

# DISPLAY

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Installing display driver packages...---------------------"
echo "------------------------------------------------------------------------"
echo ""

## Determine GPU  
if lspci | grep -E "NVIDIA|GeForce"; then
     sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
elif lspci | grep -E "Radeon"; then
    sudo  pacman -S --noconfirm xf86-video-amdgpu
elif lspci | grep -E "Integrated Graphics Controller"; then
    sudo  pacman -S --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils
fi

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
cd ~
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
yay -S --noconfirm zramd nerd-fonts-fantasque-sans-mono

### CDX
sudo pacman -S --noconfirm postgresql redis python-pip gitui github-cli
yay -S --noconfirm mongodb-bin

### PACK
yay -S --noconfirm brave-bin onlyoffice-bin

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
sudo pacman -S --noconfirm gimp kdenlive ffmpeg ffmpegthumbnailer youtube-dl simplescreenrecorder mpv
yay -S --noconfirm gimp-plugin-registry

# ENABLE ZRAM

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Enabling ZRAM...------------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

sudo sed -i '8s/.*/MAX_SIZE=724/' /etc/default/zramd
sudo systemctl enable --now zramd

# ADD FEATURES TO sudoers

echo ""
echo "-------------------------------------------------------------------------"
echo "--------------Adding insults on wrong password...------------------------"
echo "-------------------------------------------------------------------------"
echo ""

sudo sed -i '71s/.*/Defaults insults/' /etc/sudoers

# SETUP APPARMOR

echo ""
echo "------------------------------------------------------------------------"
echo "--------------Enabling APPARMOR...--------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet lsm=landlock,lockdown,yama,apparmor,bpf"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo pacman -S --noconfirm apparmor
sudo systemctl enable --now apparmor.service

echo ""
echo "------------------------------------------------------------------------"
echo "--------------COPYING SETTINGS...---------------------------------------"
echo "------------------------------------------------------------------------"
echo ""

# COPY FISH SHELL SETTINGS

fish -c "exit"
cp -r ~/setup/configs/config.fish ~/.config/fish/

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
sed -i '180 a                      --theme=gruvbox-dark --paging=never --style="$BAT_STYLE" "$@" &' ~/.config/nnn/plugins/preview-tui
sed -i '182d' ~/.config/nnn/plugins/preview-tui

# COPY KITTY SETTINGS

cp -r ~/setup/configs/kitty ~/.config/

# CHANGE DEFAULT SHELL

sudo usermod --shell /bin/fish $1
