#!/bin/sh

## Enable Multilib
sudo sed -i '94s/.*/[multilib]/' /etc/pacman.conf
sudo sed -i '95s/.*/Include = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
sudo pacman -Syyy

## Required Pacakges
sudo pacman -S --noconfirm lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
sudo pacman -S --noconfirm wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader
sudo pacman -S --noconfirm extra/mesa-utils vulkan-tools

## Clients
sudo pacman -S --noconfirm steam
yay -S --noconfirm heroic-games-launcher-bin

## MangoHud
mangoVer=$(echo "0.6.5")
wget "https://github.com/flightlessmango/MangoHud/releases/download/v$mangoVer/MangoHud-$mangoVer.r0.ge42002c.tar.gz" -O mghud.tar.gz
tar -xzvf mghud.tar.gz
cd MangoHud
./mangohud-setup.sh install
cd ..
rm -rf MangoHud
rm -rf mghud.tar.gz

## Goverlay
govlyVer1=$(echo "0.9.1")
govlyVer2=$(echo "0_9_1")
mkdir gov
cd gov
wget "https://github.com/benjamimgois/goverlay/releases/download/$govlyVer1/goverlay_$govlyVer2.tar.xz"
tar -xf "goverlay_$govlyVer2.tar.xz"
cp -r ./goverlay ~/.local/bin/
cd ..
rm -rf gov

## Feral gamemode
sudo pacman -S --noconfirm meson systemd git dbus libinih
sudo pacman -S --noconfirm gamemode

## Protonup [Proton GE]
fish -c "pip install protonup;exit"

########### NOTES ###########

### MANGOHUD AND GOVERLAY INSTALL

# yay -S --noconfirm mangohud lib32-mangohud goverlay-bin

### QUICK UNINSTALL MANGOHUD AND GOVERLAY

# mangoVer=$(echo "0.6.5")
# wget "https://github.com/flightlessmango/MangoHud/releases/download/v$mangoVer/MangoHud-$mangoVer.r0.ge42002c.tar.gz" -O mghud.tar.gz
# tar -xzvf mghud.tar.gz
# cd MangoHud
# ./mangohud-setup.sh uninstall
# cd ..
# rm -rf MangoHud
# rm -rf mghud.tar.gz

# rm -rf $HOME/.local/bin/goverlay

### SCRIPT TO EXTRACT SAVE GAME FROM HEROIC LAUNCHER

#!/bin/bash

## Choose Game
# gameList=$(ls $HOME/Games/Heroic/Prefixes/ | fzf)

## Get savegame location
# scrapeSave=$(find "$HOME/Games/Heroic/Prefixes/$gameList/pfx/drive_c/users/steamuser/AppData" -maxdepth 2 -type d | fzf)

## Get savegame
# if [[ "$scrapeSave" ]]; then
# 	cp -r "$scrapeSave" "$HOME"
# fi
