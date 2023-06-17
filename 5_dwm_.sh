#!/bin/sh

# Source Helper
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "$SCRIPT_DIR/helper.sh"

# READ ARGUMENT
uname=$1

# CORE PACAKAGES

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------Installing CORE PACKAGES FOR DWM...--------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

install "pcmanfm ark zathura zathura-pdf-mupdf dunst clipmenu" "pac"
install "xorg-server xorg-xinit xorg-xrandr xorg-xsetroot xautolock" "pac"
install "pulsemixer pamixer" "pac"
install "lxrandr brightnessctl feh xdg-user-dirs xdg-desktop-portal-kde xdg-utils" "pac"
install "mtpfs gvfs-mtp" "pac"
install "jmtpfs nsxiv-git" "yay"

### MISC

mkdir -p ~/.misc
cp -r ~/setup/configs/misc/* ~/.misc/

# Volnoti
install "dbus-glib" "pac"
git clone https://github.com/hcchu/volnoti
cd volnoti
cd res
rm display-brightness-symbolic.svg
wget https://0x0.st/Ho5Y.svg -O display-brightness-symbolic.svg
cd ..
./prepare.sh
./configure --prefix=/usr
make
sudo make clean install
cd ..
rm -rf volnoti

# Setup nsxiv key-handler
mkdir -p ~/.config/nsxiv/exec
cp -r ~/setup/configs/key-handler ~/.config/nsxiv/exec

# PICOM DISPLAY COMPOSITOR

install "libev libconfig meson ninja uthash" "pac"
# git clone https://github.com/pijulius/picom
git clone https://github.com/FT-Labs/picom
cd picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install
cd ..
rm -rf picom
cp -r ~/setup/configs/picom ~/.config/

# APPEARANCE

install "lxappearance-gtk3 qt5ct kvantum-qt5" "pac"

install "breeze-icons breeze-gtk breeze ttf-joypixels" "pac"

git clone https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme
cd ./Gruvbox-GTK-Theme/
git checkout 44e81d8226579a24a791f3acf43b97de815bc4b1
cd themes
sudo cp -r ./Gruvbox-Dark-B /usr/share/themes/
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

install "dxhd-bin" "yay"
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

# XINITRC SETUP

cp /etc/X11/xinit/xinitrc ~/.xinitrc
sed -i '51,55d' ~/.xinitrc

echo "# Startup Sound
mpv --no-video ~/.misc/startup.m4a &

# Resolution
xrandr --output eDP-1 --mode 1920x1080 &

# Picom
picom -b

# Hotkey daemon
dxhd -b &

# Wallpaper
sh ~/.local/bin/wall.sh &

# Clipboard
clipmenud &

# Dunst
dunst &

# Volume Notification
volnoti &

# Autolock
xautolock -time 10 -locker ~/.local/bin/screenLock.sh &

# dwmblocks
dwmblocks &

# Low Battery
find "$HOME/.cache/" -name 'lowbat*' -delete
~/.local/bin/lowbat.sh &

# Infinte loop
while true;do 
    ~/.config/DWM/dwm >/dev/null 2>&1 
done

# DWM Execute
exec ~/.config/DWM/dwm
" >>~/.xinitrc

# INSTALL DWM
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Installing DWM ...-------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

DWM_VER=$(echo "6.2")
cp -r ~/setup/configs/dwm-${DWM_VER}/ ~/.config/
mv ~/.config/dwm-${DWM_VER}/ ~/.config/DWM
cd ~/.config/DWM/
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

# INSTALL SCREENLOCKER
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Installing SCREENLOCKER ...----------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

pip install pynput opencv-python requests argparse playsound
cp -r ~/setup/scripts/screenLock.py ~/.local/bin/
chmod +x ~/.local/bin/screenLock.py
cp -r ~/setup/scripts/screenLock.sh ~/.local/bin/
chmod +x ~/.local/bin/screenLock.sh
install "i3lock-color" "yay"


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

xdg-settings set default-web-browser brave-browser.desktop

# REMOVE KWALLET

sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd5.service

# SDDM 

install "sddm" "pac"
cd /usr/share/sddm/themes/
sudo git clone "https://github.com/MarianArlt/sddm-sugar-light"
rep="Current=sddm-sugar-light"
sudo sed -i "33s/.*/$rep/" /usr/lib/sddm/sddm.conf.d/default.conf


sudo mkdir /usr/share/xsessions
cd /usr/share/xsessions
sudo touch dwm.desktop
sudo echo '[Desktop Entry]
Encoding=UTF-8
Name=Dwm
Comment=Dynamic window manager
Exec=dwm
Icon=dwm
Type=XSession' | sudo tee -a /usr/share/xsessions/dwm.desktop >/dev/null
cp -r ~/setup/scripts/startup.m4a ~/.local/share/sounds

sudo systemctl enable sddm

# XPROFILE

touch ~/.xprofile

echo "# Startup Sound
mpv --no-video ~/.misc/startup.m4a &

# Resolution
xrandr --output eDP-1 --mode 1920x1080 &

# Picom
picom -b

# Hotkey daemon
dxhd -b &

# Wallpaper
sh ~/.local/bin/wall.sh &

# Clipboard
clipmenud &

# Dunst
dunst &

# Volume Notification
volnoti &

# Autolock
xautolock -time 10 -locker ~/.local/bin/screenLock.sh &

# dwmblocks
dwmblocks &

# Low Battery
find "$HOME/.cache/" -name 'lowbat*' -delete
~/.local/bin/lowbat.sh &

# Infinte loop
while true;do 
    ~/.config/DWM/dwm >/dev/null 2>&1 
done

# DWM Execute
exec ~/.config/DWM/dwm
" >> ~/.xprofile
