#!/bin/sh

# Source Helper
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/helper.sh"

# CORE PACKAGES

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------Installing CORE PACKAGES FOR KDE...--------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

install "plasma-desktop plasma-workspace plasma-nm plasma-pa qt5-tools" "pac"

install "breeze breeze-gtk kde-gtk-config kdecoration" "pac"

install "powerdevil xdg-desktop-portal-kde" "pac"

install "kwrited kwin kgamma5 khotkeys kinfocenter kscreen systemsettings sddm sddm-kcm" "pac"

# PACKAGES

install "dolphin ark zathura zathura-pdf-mupdf clipmenu dmenu" "pac"
install "nsxiv-git" "yay"
install "pulsemixer pamixer" "pac"
install "brightnessctl" "pac"

# Setup nsxiv key-handler
mkdir -p ~/.config/nsxiv/exec
cp -r ~/setup/configs/key-handler ~/.config/nsxiv/exec

# REMOVE KWALLET

sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd5.service

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Creating xinitrc...---------------------------------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

# XINIT SETUP

cp /etc/X11/xinit/xinitrc ~/.xinitrc
sed -i '51,55d' ~/.xinitrc

echo "# Picom
picom -b --animations --animation-window-mass 0.5 --animation-for-open-window zoom --animation-stiffness 350 --experimental-backends

# Hotkey daemon
dxhd -b &

# Clipboard
clipmenud &

# Volume Notification
volnoti &
" >>~/.xprofile

# ENABLE SDDM

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------ENABLE LOGIN MANAGER SDDM...---------------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

sudo systemctl enable sddm

# REGISTER KITTY IN DOLPHIN

echo ""
echo "--------------------------------------------------------------------------------"
echo "--------------Register Kitty in Dolphin...--------------------------------------"
echo "--------------------------------------------------------------------------------"
echo ""

mkdir -p ~/.local/share/kservices5
cp -r ~/setup/configs/kittyhere.desktop ~/.local/share/kservices5

# SETUP DXHD

echo ""
echo "-------------------------------------------------------------------------------"
echo "--------------Installing Hotkey Daemon...--------------------------------------"
echo "-------------------------------------------------------------------------------"
echo ""

install "dxhd-bin" "yay"
mkdir -p ~/.config/dxhd
mv ~/setup/configs/dxhd/dxhd_kde.sh ~/.config/dxhd
mv ~/.config/dxhd/dxhd_kde.sh ~/.config/dxhd/dxhd.sh
# mkdir -p ~/.config/systemd/user
# cp -r ~/setup/configs/dxhd/dxhd.service ~/.config/systemd/user
# systemctl --user enable dxhd.service

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Setting default application for filetypes...--------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

# UPDATE MIMETYPE

touch ~/zathura.desktop
sudo touch zathura.desktop
cp -r ~/setup/configs/zathura ~/.config

sudo echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Zathura
Comment=A minimalistic PDF viewer
Comment[de]=Ein minimalistischer PDF-Betrachter
Exec=zathura %f
Terminal=false
Categories=Office;Viewer;
MimeType=application/pdf;
" >>~/zathura.desktop
sudo mv ~/zathura.desktop /usr/share/applications

xdg-mime default nsxiv.desktop image/png
xdg-mime default nsxiv.desktop image/jpg
xdg-mime default nsxiv.desktop image/jpeg
xdg-mime default mpv.desktop image/gif
xdg-mime default zathura.desktop application/pdf

wget https://gist.githubusercontent.com/acrisci/b264c4b8e7f93a21c13065d9282dfa4a/raw/8c2b2a57ac74c2fd7c26d02d57203cc746e7d3cd/default-media-player.sh
bash ./default-media-player.sh mpv.desktop
rm -rf default-media-player.sh

xdg-mime default dolphin.desktop inode/directory

echo "Done seting default application!"
echo ""
