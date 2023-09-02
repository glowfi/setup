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

install "xorg-server xorg-xinit xorg-xrandr xorg-xsetroot xautolock" "pac"
install "xdg-user-dirs xdg-desktop-portal-kde xdg-utils" "pac"
install "wmctrl" "pac"

install "pcmanfm ark zathura zathura-pdf-mupdf dunst clipmenu" "pac"
install "feh" "pac"
install "nsxiv-git" "yay"

install "pulsemixer pamixer" "pac"
install "lxrandr brightnessctl" "pac"
install "redshift" "pac"

install "mtpfs gvfs-mtp" "pac"
install "jmtpfs" "yay"

### MISC

mkdir -p $HOME/.misc
cp -r $HOME/setup/configs/misc/* $HOME/.misc/

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
mkdir -p $HOME/.config/nsxiv/exec
cp -r $HOME/setup/configs/key-handler $HOME/.config/nsxiv/exec

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
cp -r $HOME/setup/configs/picom $HOME/.config/

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

cd $HOME/Downloads/
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
mkdir -p $HOME/.config/dxhd
mv $HOME/setup/configs/dxhd/dxhd_dwm.sh $HOME/.config/dxhd
mv $HOME/.config/dxhd/dxhd_dwm.sh $HOME/.config/dxhd/dxhd.sh

echo ""
echo "----------------------------------------------------------------------------------------"
echo "--------------Creating wallpaper script...----------------------------------------------"
echo "----------------------------------------------------------------------------------------"
echo ""

# WALLPAPER SCRIPT

touch $HOME/.local/bin/wall.sh
echo '#!/bin/sh
while true; do
	feh --bg-fill "$(find $HOME/wall -type f | shuf -n 1)"
	sleep 900s
done
' >>$HOME/.local/bin/wall.sh

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Creating xinitrc...---------------------------------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

# XINITRC SETUP

cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
sed -i '51,55d' $HOME/.xinitrc

echo '# Resolution
xrandr --output eDP-1 --mode 1920x1080 &

# Picom
picom -b

# Hotkey daemon
dxhd -b &

# Wallpaper
sh $HOME/.local/bin/wall.sh &

# Clipboard
clipmenud &

# Dunst
dunst &

# Volume Notification
volnoti &

# Autolock
xautolock -time 10 -locker $HOME/.local/bin/screenlocker &

# Bluelight Filter
$HOME/.local/bin/bfilter.sh &

# dwmblocks
dwmblocks &

# Low Battery
find "$HOME/.cache/" -name "lowbat*" -delete
$HOME/.local/bin/lowbat.sh &

# Infinte loop
while true;do
    $HOME/.config/DWM/dwm >/dev/null 2>&1
done

# DWM Execute
exec $HOME/.config/DWM/dwm
' >>$HOME/.xinitrc

# INSTALL DWM
echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Installing DWM ...-------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

DWM_VER=$(echo "6.2")
cp -r $HOME/setup/configs/dwm-${DWM_VER}/ $HOME/.config/
mv $HOME/.config/dwm-${DWM_VER}/ $HOME/.config/DWM
cd $HOME/.config/DWM/
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

cd $HOME/setup/configs/dmenu
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

pip install opencv-python tk pynput playsound pathlib pyautogui
git clone https://github.com/glowfi/screenlocker
cd screenlocker
fish -c "cargo build --release"
mv ./target/release/screenlocker $HOME/.local/bin/screenlocker
cd ..
rm -rf screenlocker



# COPY TOPBAR SETTINGS
echo ""
echo "----------------------------------------------------------------------------------------------------"
echo "--------------Copying TOPBAR settings...------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------"
echo ""

cp -r $HOME/setup/configs/dwmblocks/modules/* $HOME/.local/bin/
cd $HOME/setup/configs/dwmblocks/
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

cp -r $HOME/setup/configs/dunst/ $HOME/.config
cp -r $HOME/setup/scripts/audio.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/audio.sh
cd
echo "Done Copying DUNST settings!"
echo ""

# Copy XRESOURCES
echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Copying Xresources...----------------------------------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

cp -r $HOME/setup/configs/.Xresources $HOME

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Setting default application for filetypes...--------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

# UPDATE MIMETYPE

touch $HOME/zathura.desktop
sudo touch zathura.desktop
cp -r $HOME/setup/configs/zathura $HOME/.config

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
" >>$HOME/zathura.desktop
sudo mv $HOME/zathura.desktop /usr/share/applications

xdg-mime default nsxiv.desktop image/png
xdg-mime default nsxiv.desktop image/jpg
xdg-mime default nsxiv.desktop image/jpeg
xdg-mime default mpv.desktop image/gif
xdg-mime default zathura.desktop application/pdf

wget https://gist.githubusercontent.com/acrisci/b264c4b8e7f93a21c13065d9282dfa4a/raw/8c2b2a57ac74c2fd7c26d02d57203cc746e7d3cd/default-media-player.sh
bash ./default-media-player.sh mpv.desktop
rm -rf default-media-player.sh

xdg-mime default pcmanfm.desktop inode/directory

xdg-settings set default-web-browser brave-browser.desktop

echo "Done seting default application!"
echo ""

# THEMING

cd $HOME/.config;rm -rf qt5ct/ gtk-2.0/ gtk-3.0/ Kvantum/;cd ;rm $HOME/.gtkrc-2.0;rm -rf $HOME/.config/gtk-3.0/bookmarks

cp -r $HOME/setup/configs/theming/qt5ct/ $HOME/setup/configs/theming/gtk-2.0 $HOME/setup/configs/theming/gtk-3.0 $HOME/setup/configs/theming/Kvantum $HOME/.config
cp -r $HOME/setup/configs/theming/.gtkrc-2.0 $HOME
echo "file:///home/$USER/Documents Documents" >> $HOME/.config/gtk-3.0/bookmarks
echo "file:///home/$USER/Downloads Downloads" >> $HOME/.config/gtk-3.0/bookmarks
echo "file:///home/$USER/Pictures Pictures" >> $HOME/.config/gtk-3.0/bookmarks
echo "file:///home/$USER/Videos Videos" >> $HOME/.config/gtk-3.0/bookmarks

# REMOVE KWALLET

sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd5.service
