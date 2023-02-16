#!/bin/sh

# READ ARGUMENT
uname=$1

# CORE PACAKAGES

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------Installing CORE PACKAGES FOR DWM...--------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

sudo pacman -S --noconfirm pcmanfm ark zathura zathura-pdf-mupdf dunst clipmenu
sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-xrandr xorg-xsetroot xautolock
sudo pacman -S --noconfirm pulsemixer pamixer
sudo pacman -S --noconfirm lxrandr brightnessctl feh xdg-user-dirs xdg-desktop-portal-kde xdg-utils
sudo pacman -S --noconfirm mtpfs gvfs-mtp
yay -S --noconfirm jmtpfs nsxiv-git
yay -S --noconfirm volnoti

# Setup nsxiv key-handler
mkdir -p ~/.config/nsxiv/exec
cp -r ~/setup/configs/key-handler ~/.config/nsxiv/exec

# PICOM DISPLAY COMPOSITOR

sudo pacman -S --noconfirm libev libconfig meson ninja uthash
git clone https://github.com/pijulius/picom
cd picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install
cd ..
rm -rf picom

# APPEARANCE

sudo pacman -S --noconfirm lxappearance-gtk3 qt5ct kvantum-qt5
sudo pacman -S --noconfirm breeze-icons breeze-gtk breeze ttf-joypixels papirus-icon-theme

git clone https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme
cd ./Gruvbox-GTK-Theme/themes
sudo cp -r ./* /usr/share/themes/
cd ../../
rm -rf Gruvbox-GTK-Theme

git clone https://github.com/TheGreatMcPain/gruvbox-material-gtk
cd gruvbox-material-gtk
sudo cp -r ./icons/Gruvbox-Material-Dark/ /usr/share/icons/
cd ..
rm -rf gruvbox-material-gtk

cd ~/Downloads/
wget 'https://0x0.st/HryC.tar.gz'
tar xzvf HryC.tar.gz
rm HryC.tar.gz
sudo mv ./Gruvbox-Dark-Blue/ /usr/share/Kvantum/
cd

# SETUP DXHD

echo ""
echo "-------------------------------------------------------------------------------"
echo "--------------Installing Hotkey Daemon...--------------------------------------"
echo "-------------------------------------------------------------------------------"
echo ""

yay -S --noconfirm dxhd-bin
mkdir -p ~/.config/dxhd
mv ~/setup/configs/dxhd/dxhd_dwm.sh ~/.config/dxhd
mv ~/.config/dxhd/dxhd_dwm.sh ~/.config/dxhd/dxhd.sh

echo ""
echo "----------------------------------------------------------------------------------------"
echo "--------------Creating wallpaper script...----------------------------------------------"
echo "----------------------------------------------------------------------------------------"
echo ""

# WALLPAPER SCRIPT

touch ~/.local/bin/wall.sh
echo '#!/bin/sh
while true; do
	feh --bg-fill "$(find ~/wall -type f | shuf -n 1)"
	sleep 900s
done
' >>~/.local/bin/wall.sh

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Creating xinitrc...---------------------------------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

# XINIT SETUP

cp /etc/X11/xinit/xinitrc ~/.xinitrc
sed -i '51,55d' ~/.xinitrc

echo "# Resolution
xrandr --output eDP-1 --mode 1920x1080 &

# Picom
picom -b --animations --animation-window-mass 0.5 --animation-for-open-window zoom --animation-stiffness 350 --experimental-backends

# Hotkey daemon
dxhd -b &

# Wallpaper
sh ~/.local/bin/wall.sh &

# Clipboard
clipmenud &

# Volume Notification
volnoti &

# Autolock
xautolock -time 10 -locker slock &

# dwmblocks
dwmblocks &

# Infinte loop
while true;do 
    ~/.config/dwm-6.4/dwm >/dev/null 2>&1 
done

# DWM Execute
exec ~/.config/dwm-6.4/dwm
" >>~/.xinitrc

# INSTALL DWM
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Installing DWM ...-------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

cp -r ~/setup/configs/dwm-6.4/ ~/.config/
cd ~/.config/dwm-6.4/
make
cd ..
echo "Done Installing DWM!"
echo ""

# INSTALL DEMNU
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Installing DMENU ...-----------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

cd ~/setup/configs/dmenu
sudo make clean install
cd ..
echo "Done Installing DEMNU!"
echo ""

# INSTALL SLOCK
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Installing SLOCK ...-----------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

cd ~/setup/configs/slock
output=$(getent passwd "$uname" | cut -d ':' -f 5 | awk -F" " '{print $1}')
output1=$(echo $output | awk '{ print toupper($0) }')
sudo sed -i "2s/.*/static const char *user  = \""$uname"\";/" ~/setup/configs/slock/config.def.h
sudo sed -i "3s/.*/static const char *group = \""$uname"\";/" ~/setup/configs/slock/config.def.h
sudo sed -i "s/replacehere/"$output"/g" ~/setup/configs/slock/slock.c
sudo sed -i "s/Replacehere/"$output1"/g" ~/setup/configs/slock/slock.c
sudo mv ~/setup/configs/slock/slock@.service /etc/systemd/system/slock@.service
sudo cp config.def.h config.h
sudo make clean install
sudo systemctl enable slock@$uname.service
cd ..
echo "Done Installing SLOCK!"
echo ""

# COPY TOPBAR SETTINGS
echo ""
echo "----------------------------------------------------------------------------------------------------"
echo "--------------Copying TOPBAR settings...------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------"
echo ""

cp -r ~/setup/configs/dwmblocks/modules/* ~/.local/bin/
cd ~/setup/configs/dwmblocks/
sudo make clean install
cd
echo "Done Copying TOPBAR settings!"
echo ""

# COPY DUNST SETTINGS
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Copying DUNST settings...------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

cp -r ~/setup/configs/dunst/ ~/.config
mkdir -p ~/.local/share/sounds
cp -r ~/setup/scripts/audio.ogg ~/.local/share/sounds
cp -r ~/setup/scripts/audio.sh ~/.local/bin/
chmod +x ~/.local/bin/audio.sh
cd
echo "Done Copying DUNST settings!"
echo ""

# Copy XRESOURCES
echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Copying Xresources...----------------------------------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

cp -r ~/setup/configs/.Xresources ~

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

xdg-mime default pcmanfm.desktop inode/directory

echo "Done seting default application!"
echo ""

xdg-settings set default-web-browser firefox.desktop

# REMOVE KWALLET

sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd5.service
