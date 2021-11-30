#!/bin/sh

# CORE PACKAGES

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------Installing CORE PACKAGES FOR KDE...--------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

sudo pacman -S --noconfirm plasma-desktop plasma-workspace plasma-nm plasma-pa qt5-tools

sudo pacman -S --noconfirm breeze breeze-gtk kde-gtk-config kdecoration

sudo pacman -S --noconfirm powerdevil xdg-desktop-portal-kde

sudo pacman -S --noconfirm kwrited kwin kgamma5 khotkeys kinfocenter kscreen systemsettings sddm sddm-kcm

# PACKAGES

# sudo pacman -S --noconfirm dolphin ark gwenview okular flameshot 
sudo pacman -S --noconfirm dolphin ark sxiv zathura zathura-pdf-poppler flameshot 


# REMOVE KWALLET

sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd5.service

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

yay -S --noconfirm dxhd-bin
mkdir -p ~/.config/dxhd
mv ~/setup/configs/dxhd/dxhd_kde.sh ~/.config/dxhd
mv ~/.config/dxhd/dxhd_kde.sh ~/.config/dxhd/dxhd.sh
mkdir -p ~/.config/systemd/user
cp -r ~/setup/configs/dxhd/dxhd.service ~/.config/systemd/user
systemctl --user enable dxhd.service

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
" >> ~/zathura.desktop
sudo mv ~/zathura.desktop /usr/share/applications


xdg-mime default sxiv.desktop image/png
xdg-mime default sxiv.desktop image/jpg
xdg-mime default sxiv.desktop image/jpeg
xdg-mime default zathura.desktop application/pdf
