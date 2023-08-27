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

install "kwrited kwin kgamma5 khotkeys kinfocenter kscreen systemsettings sddm sddm-kcm libnotify" "pac"

# PACKAGES

install "dolphin ark zathura zathura-pdf-mupdf clipmenu dmenu" "pac"
install "wmctrl" "pac"
install "nsxiv-git" "yay"
install "pulsemixer pamixer" "pac"
install "brightnessctl" "pac"

# Volnoti
install "gtk2" "pac"
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

echo ""
echo "----------------------------------------------------------------------------------------"
echo "--------------Creating wallpaper script...----------------------------------------------"
echo "----------------------------------------------------------------------------------------"
echo ""

# WALLPAPER SCRIPT

touch $HOME/.local/bin/wall.sh
echo '#!/bin/sh
while true; do
    kwriteconfig5 --file "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" --group "Containments" --group "1" --group "Wallpaper" --group "org.kde.image" --group "General" --key "Image" "$(find $HOME/wall -type f | shuf -n 1)"
	sleep 900s
done
' >>$HOME/.local/bin/wall.sh

### MISC

mkdir -p $HOME/.misc
cp -r $HOME/setup/configs/misc/* $HOME/.misc/

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Creating xprofile...--------------------------------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

# XPROFILE SETUP

touch $HOME/.xprofile

echo "# Hotkey daemon
dxhd -b &

# Wallpaper
sh $HOME/.local/bin/wall.sh &

# Clipboard
clipmenud &

# Volume Notification
volnoti &
" >>$HOME/.xprofile

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

mkdir -p $HOME/.local/share/kservices5
cp -r $HOME/setup/configs/kittyhere.desktop $HOME/.local/share/kservices5

# SETUP DXHD

echo ""
echo "-------------------------------------------------------------------------------"
echo "--------------Installing Hotkey Daemon...--------------------------------------"
echo "-------------------------------------------------------------------------------"
echo ""

install "dxhd-bin" "yay"
mkdir -p $HOME/.config/dxhd
mv $HOME/setup/configs/dxhd/dxhd_kde.sh $HOME/.config/dxhd
mv $HOME/.config/dxhd/dxhd_kde.sh $HOME/.config/dxhd/dxhd.sh
# mkdir -p $HOME/.config/systemd/user
# cp -r $HOME/setup/configs/dxhd/dxhd.service $HOME/.config/systemd/user
# systemctl --user enable dxhd.service

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

xdg-mime default dolphin.desktop inode/directory

xdg-settings set default-web-browser brave-browser.desktop

echo "Done seting default application!"
echo ""

# Disable app launch feedback

sudo kwriteconfig5 --file klaunchrc --group BusyCursorSettings --key "Bouncing" --type bool false
sudo kwriteconfig5 --file klaunchrc --group FeedbackStyle --key "BusyCursor" --type bool false

# REMOVE KWALLET

sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd5.service
