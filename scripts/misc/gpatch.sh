#!/bin/sh

### Enable Multilib

varInit=$(cat /proc/1/comm)
if [[ "$varInit" = "systemd" ]]; then
	sudo sed -i '94s/.*/[multilib]/' /etc/pacman.conf
	sudo sed -i '95s/.*/Include = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
	sudo pacman -Syyy
else
	sudo sed -i '97s/.*/[lib32]/' /etc/pacman.conf
	sudo sed -i '98s/.*/Include = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf
	sudo tee -a /etc/pacman.conf <<EOF

[multilib]
Include = /etc/pacman.d/mirrorlist-arch
EOF
	sudo pacman -Syyy
fi

### Required Packages

for i in {1..5}; do sudo pacman -S --noconfirm lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader && break || sleep 1; done
for i in {1..5}; do yes | sudo pacman -S wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader && break || sleep 1; done
for i in {1..5}; do sudo pacman -S --noconfirm extra/mesa-utils vulkan-tools && break || sleep 1; done
for i in {1..5}; do yay -S --noconfirm protontricks-git && break || sleep 1; done

### Clients

for i in {1..5}; do sudo pacman -S --noconfirm steam && break || sleep 1; done
# for i in {1..5}; do yay -S --noconfirm heroic-games-launcher-bin && break || sleep 1; done
# for i in {1..5}; do yay -S --noconfirm protonup-qt-bin && break || sleep 1; done

### MangoHud

for i in {1..5}; do yay -S --noconfirm mangohud lib32-mangohud && break || sleep 1; done
mkdir -p "$HOME/.config/MangoHud/"
cd "$HOME/.config/MangoHud/"
wget "https://raw.githubusercontent.com/glowfi/setup/main/storage/MangoHud.conf" -O "MangoHud.conf"

### Goverlay

for i in {1..5}; do sudo pacman -S --noconfirm goverlay && break || sleep 1; done
mkdir -p "$HOME/.config/goverlay/"
cd "$HOME/.config/goverlay/"
wget "https://raw.githubusercontent.com/glowfi/setup/main/storage/MangoHud.conf" -O "MangoHud.conf"
cd

### Feral gamemode

for i in {1..5}; do sudo pacman -S --noconfirm meson git dbus libinih && break || sleep 1; done
for i in {1..5}; do sudo pacman -S --noconfirm gamemode && break || sleep 1; done

### Save Scraper and Save Retriever from cloud

cp -r $HOME/setup/scripts/misc/saveScraper.py $HOME/.local/bin/
chmod +x $HOME/.local/bin/saveScraper.py
