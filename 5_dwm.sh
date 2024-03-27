#!/bin/sh

# Source Helper
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
DETECT_INIT_SCRIPT="$SCRIPT_DIR/detectInit.sh"
source "$SCRIPT_DIR/helper.sh"

# Git clone helper
klone() {
	for ((i = 0; i < 10; i++)); do
		git clone "$1" && break
	done

}

# Get Init Type
initType=$(bash "${DETECT_INIT_SCRIPT}")

## Get username
uname=$(echo "$USER")

# CORE PACKAGES

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
klone "https://github.com/hcchu/volnoti"
cd volnoti
cd res
rm display-brightness-symbolic.svg
mv "${SCRIPT_DIR}/storage/display-brightness-symbolic.svg" ./display-brightness-symbolic.svg
cd ..
./prepare.sh
./configure --prefix=/usr
make
sudo make clean install
cd ..
rm -rf volnoti

# Setup nsxiv key-handler

mkdir -p $HOME/.config/nsxiv/exec
cp -r $HOME/setup/configs/nsxiv/key-handler $HOME/.config/nsxiv/exec

# Install picom compositor

install "libev libconfig meson ninja uthash" "pac"
klone "https://github.com/FT-Labs/picom"
cd picom
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install
cd ..
rm -rf picom
cp -r $HOME/setup/configs/picom $HOME/.config/

# Appearance

install "lxappearance-gtk3 qt6ct kvantum" "pac"

install "breeze-icons breeze-gtk breeze ttf-joypixels" "pac"

klone "https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme"
cd ./Gruvbox-GTK-Theme/
git checkout 44e81d8226579a24a791f3acf43b97de815bc4b1
cd themes
sudo cp -r ./Gruvbox-Dark-B /usr/share/themes/
cd ../../
rm -rf Gruvbox-GTK-Theme

klone "https://github.com/TheGreatMcPain/gruvbox-material-gtk"
cd gruvbox-material-gtk
sudo cp -r ./icons/Gruvbox-Material-Dark/ /usr/share/icons/
cd ..
rm -rf gruvbox-material-gtk

cd $HOME/Downloads/
mv "${SCRIPT_DIR}/storage/Gruvbox-Dark-Blue.tar.gz" .
tar xzvf Gruvbox-Dark-Blue.tar.gz
rm Gruvbox-Dark-Blue.tar.gz
sudo mv ./Gruvbox-Dark-Blue/ /usr/share/Kvantum/
cd

# Theming

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Theming...------------------------------------------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

cp -r $HOME/setup/configs/.Xresources $HOME
cd $HOME/.config;rm -rf qt6ct/ gtk-2.0/ gtk-3.0/ Kvantum/;cd ;rm $HOME/.gtkrc-2.0;rm -rf $HOME/.config/gtk-3.0/bookmarks

cp -r $HOME/setup/configs/DWM/theming/qt6ct/ $HOME/setup/configs/DWM/theming/gtk-2.0 $HOME/setup/configs/DWM/theming/gtk-3.0 $HOME/setup/configs/DWM/theming/Kvantum $HOME/.config
cp -r $HOME/setup/configs/DWM/theming/.gtkrc-2.0 $HOME
echo "file:///home/$USER/Documents Documents" >> $HOME/.config/gtk-3.0/bookmarks
echo "file:///home/$USER/Downloads Downloads" >> $HOME/.config/gtk-3.0/bookmarks
echo "file:///home/$USER/Pictures Pictures" >> $HOME/.config/gtk-3.0/bookmarks
echo "file:///home/$USER/Videos Videos" >> $HOME/.config/gtk-3.0/bookmarks
getReq=$(cat "$HOME/.gtkrc-2.0" | grep -n "replacethis" | head -1 | xargs)
getLineNumber=$(echo "$getReq" | cut -d":" -f1)
rep=$(echo 'include "\/home\/$USER\/.gtkrc-2.0.mine"')
sudo sed -i "${getLineNumber}s/.*/${rep}/" $HOME/.gtkrc-2.0
sed "s/\$USER/$USER/" .gtkrc-2.0


# SETUP hkd

echo ""
echo "-------------------------------------------------------------------------------"
echo "--------------Installing Hotkey Daemon...--------------------------------------"
echo "-------------------------------------------------------------------------------"
echo ""

cp -r ~/setup/configs/hkd/ ~/.config/
cd ~/.config/hkd
mv ~/.config/hkd/scripts_dwm/ ~/.config/hkd/scripts
mv ~/.config/hkd/config_dwm ~/.config/hkd/config
rm -rf scripts_kde config_kde
make clean 
make
sudo usermod -a -G input "$USER"

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

if [[ "$initType" != "systemD" ]]; then
    pipeStr="artix-pipewire-loader &"
else
    pipeStr="systemctl --user start pipewire.service pipewire.socket wireplumber.service pipewire-pulse.service pipewire-pulse.socket pipewire-session-manager.service"
fi

echo "# Resolution
xrandr --output eDP-1 --mode 1920x1080 &

# Picom
picom -b

# Pipewire
${pipeStr}
"'
# Hotkey daemon
~/.config/hkd/hkd &

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
redshift -P -O 4500K &

# dwmblocks
dwmblocks &

# Window switcher
alttab -fg "#d58681" -bg "#4a4a4a" -frame "#eb564d" -t 128x150 -i 127x64 -w 1 &

# Low Battery
find "$HOME/.cache/" -name "lowbat*" -delete
$HOME/.local/bin/lowbat.sh &

# Infinte loop
while true;do
    $HOME/.config/DWM/dwm >/dev/null 2>&1
done

# DWM Execute
exec $HOME/.config/DWM/dwm' >>$HOME/.xinitrc

# Window Switcher

git clone https://github.com/sagb/alttab.git
cd alttab
./configure && sudo make install
cd ..
sudo rm -rf alttab

# Install DWM

echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Installing DWM ...-------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

DWM_VER=$(echo "6.2")
cp -r $HOME/setup/configs/DWM/dwm-${DWM_VER}/ $HOME/.config/
mv $HOME/.config/dwm-${DWM_VER}/ $HOME/.config/DWM
cd $HOME/.config/DWM/
make
cd
echo "Done Installing DWM!"
echo ""

# Install Launcher-menu

echo ""
echo "-----------------------------------------------------------------------------------------------------------"
echo "--------------Installing Launcher MENU ...-----------------------------------------------------------------"
echo "-----------------------------------------------------------------------------------------------------------"
echo ""

sudo rm -rf /usr/local/bin/bemenu /usr/local/bin/bemenu-app/ /usr/local/bin/bemenu-run 
cd $HOME/setup/configs/bemenu-app/
./help.sh x11
cd ..
sudo mv ./bemenu-app/ /usr/local/bin/
sudo mv /usr/local/bin/bemenu-app/bemenu /usr/local/bin/
sudo mv /usr/local/bin/bemenu-app/bemenu-run /usr/local/bin/
cd

# Install screenlocker

echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Installing SCREENLOCKER ...----------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

pip install opencv-python tk pynput playsound pathlib pyautogui
install "tk" "pac"
klone "https://github.com/glowfi/screenlocker"
cd screenlocker
fish -c "cargo build --release"
mv ./target/release/screenlocker $HOME/.local/bin/screenlocker
cd ..
rm -rf screenlocker

# Copy TOPBAR Settings

echo ""
echo "----------------------------------------------------------------------------------------------------"
echo "--------------Copying TOPBAR settings...------------------------------------------------------------"
echo "----------------------------------------------------------------------------------------------------"
echo ""

cp -r $HOME/setup/configs/DWM/dwmblocks/modules/* $HOME/.local/bin/
cd $HOME/setup/configs/DWM/dwmblocks/
sudo make clean install
cd
echo "Done Copying TOPBAR settings!"
echo ""

# Copy DUNST Settings

echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Copying DUNST settings...------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

cp -r $HOME/setup/configs/DWM/dunst/ $HOME/.config
cp -r $HOME/setup/scripts/system/audio.sh $HOME/.local/bin/
chmod +x $HOME/.local/bin/audio.sh
cd
echo "Done Copying DUNST settings!"
echo ""

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Setting default application for filetypes...--------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

# Update MIMETYPE

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

xdg-mime default zathura.desktop application/pdf

xdg-mime default nsxiv.desktop image/png
xdg-mime default nsxiv.desktop image/jpg
xdg-mime default nsxiv.desktop image/jpeg

wget https://gist.githubusercontent.com/acrisci/b264c4b8e7f93a21c13065d9282dfa4a/raw/8c2b2a57ac74c2fd7c26d02d57203cc746e7d3cd/default-media-player.sh
bash ./default-media-player.sh mpv.desktop
rm -rf default-media-player.sh
xdg-mime default mpv.desktop image/gif

xdg-mime default pcmanfm.desktop inode/directory

xdg-settings set default-web-browser brave-browser.desktop

echo "Done seting default application!"
echo ""

# Add Env

sudo tee -a /etc/environment << EOF

# Clipmenu
CM_LAUNCHER=bemenu
EOF

# Remove kwallet

sudo -u "$USER" kwriteconfig6 --file kwalletrc --group 'Wallet' --key 'Enabled' 'false'
sudo -u "$USER" kwriteconfig6 --file kwalletrc --group 'Wallet' --key 'First Use' 'false'
sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd6.service
