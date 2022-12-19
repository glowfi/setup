#!/bin/sh

## Enable Multilib
sudo sed -i '94s/.*/[multilib]/' /etc/pacman.conf
sudo sed -i '95s/.*/Include = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
sudo pacman -Syyy

## Required Pacakges
sudo pacman -S --noconfirm lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
sudo pacman -S --noconfirm wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader
sudo pacman -S --noconfirm extra/mesa-utils

## Clients
sudo pacman -S --noconfirm steam
yay -S --noconfirm heroic-games-launcher-bin

## MangoHud
yay -S --noconfirm mangohud goverlay-bin
wget https://github.com/flightlessmango/MangoHud/releases/download/v0.6.6-1/MangoHud-0.6.6.1.r0.gda573e8.tar.gz -O mghud32.tar.gz
tar -xzvf mghud32.tar.gz
cd MangoHud
./mangohud-setup.sh install
cd ..
rm -rf MangoHud
rm -rf mghud32.tar.gz

## Feral gamemode
sudo pacman -S --noconfirm meson systemd git dbus libinih
sudo pacman -S --noconfirm gamemode

## Protonup [Proton GE]
fish -c "pip install protonup;exit"
