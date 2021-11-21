#!/bin/sh

# DE

sudo pacman -S --noconfirm plasma-desktop plasma-workspace plasma-nm plasma-pa qt5-tools

sudo pacman -S --noconfirm breeze breeze-gtk kde-gtk-config kdecoration

sudo pacman -S --noconfirm powerdevil xdg-desktop-portal-kde

sudo pacman -S --noconfirm kwrited kwin kgamma5 khotkeys kinfocenter kscreen systemsettings sddm sddm-kcm

# PACKAGES

sudo pacman -S --noconfirm dolphin ark gwenview okular flameshot 


# REMOVE KWALLET

sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd5.service

# ENABLE SDDM

sudo systemctl enable sddm

# REGISTER KITTY IN DOLPHIN

mkdir -p ~/.local/share/kservices5
cp -r ~/setup/configs/kittyhere.desktop ~/.local/share/kservices5

# SETUP DXHD

yay -S --noconfirm dxhd-bin
mkdir -p ~/.config/dxhd
mv ~/setup/configs/dxhd/dxhd_kde.sh ~/.config/dxhd
mv ~/.config/dxhd/dxhd_kde.sh ~/.config/dxhd/dxhd.sh
mkdir -p ~/.config/systemd/user
cp -r ~/setup/configs/dxhd/dxhd.service ~/.config/systemd/user
systemctl --user enable dxhd.service
