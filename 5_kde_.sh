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

install "kwrited kwin kgamma5 khotkeys kinfocenter kscreen systemsettings sddm sddm-kcm libnotify konqueror" "pac"

# PACKAGES

install "xorg-xrandr" "pac"
install "xautolock" "pac"
install "wmctrl" "pac"
install "dolphin ark zathura zathura-pdf-mupdf clipmenu" "pac"
install "nsxiv-git" "yay"
install "pulsemixer pamixer" "pac"
install "brightnessctl" "pac"

# Setup nsxiv key-handler
mkdir -p $HOME/.config/nsxiv/exec
cp -r $HOME/setup/configs/key-handler $HOME/.config/nsxiv/exec

# Install DEMNU

cd $HOME/setup/configs/dmenu
sudo make clean install
cd

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

echo ""
echo "----------------------------------------------------------------------------------------"
echo "--------------Creating wallpaper script...----------------------------------------------"
echo "----------------------------------------------------------------------------------------"
echo ""

# WALLPAPER SCRIPT

touch $HOME/.local/bin/wall.sh
cat <<EOF >> $HOME/.local/bin/wall.sh
#!/bin/sh
while true; do
    randImage=\$(find ~/wall -type f | shuf -n 1)
    dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript "string:
    var Desktops = desktops();                                                                                                                       
    for (i=0;i<Desktops.length;i++) {
            d = Desktops[i];
            d.wallpaperPlugin = 'org.kde.image';
            d.currentConfigGroup = Array('Wallpaper',
                                        'org.kde.image',
                                        'General');
            d.writeConfig('Image', '\$randImage');
    }"
	sleep 900s
done
EOF
chmod +x $HOME/.local/bin/wall.sh

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

# Pipewire
systemctl --user start pipewire.service pipewire.socket wireplumber.service pipewire-pulse.service pipewire-pulse.socket pipewire-session-manager.service

# Wallpaper
sh $HOME/.local/bin/wall.sh &

# Autolock
xautolock -time 10 -locker $HOME/.local/bin/screenlocker &

# Clipboard
clipmenud &
" >>$HOME/.xprofile

# ENABLE SDDM

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------ENABLE LOGIN MANAGER SDDM...---------------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

# Enable
sudo systemctl enable sddm

# Set SDDM theme
getReq=$(cat /usr/lib/sddm/sddm.conf.d/default.conf | grep -n "Current=" | head -1 | xargs)
getLineNumber=$(echo "$getReq" | cut -d":" -f1)
rep="Current=breeze"
sudo sed -i "${getLineNumber}s/.*/${rep}/" /usr/lib/sddm/sddm.conf.d/default.conf


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

### Plasma UI Settings

# Set Plasma theme

sudo -u "${USER}" kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage "org.kde.breezedark.desktop"

# Disable splash screen

sudo -u "${USER}" kwriteconfig5 --file ksplashrc --group KSplash --key Engine "none"
sudo -u "${USER}" kwriteconfig5 --file ksplashrc --group KSplash --key Theme "none"

# Enable 9 desktops

for i in {1..9}
do
    sudo -u "${USER}" kwriteconfig5 --file kwinrc --group Desktops --key "Name_${i}" "Desktop ${i}"
    sudo -u "${USER}" kwriteconfig5 --file kwinrc --group Desktops --key Number "${i}"
    sudo -u "${USER}" kwriteconfig5 --file kwinrc --group Desktops --key Rows "1"
done

# Add command output widget

wget 'https://0x0.st/Hph4.plasmoid' -O command-output.plasmoid
plasmapkg2 -i command-output.plasmoid
rm -rf command-output.plasmoid
cp -r ~/setup/configs/plasma/kdestatus.sh ~/.local/bin/

# Use KDE file picker in GTK applications

sudo tee -a /etc/environment << EOF

# KDE file picker
GTK_USE_PORTAL=1
EOF

# Copy Xresources

cp -r $HOME/setup/configs/.Xresources $HOME

# Restore Settings

cp -r $HOME/setup/configs/plasma/plasmashellrc ~/.config/
cp -r $HOME/setup/configs/plasma/plasma-org.kde.plasma.desktop-appletsrc ~/.config/

### Shortcuts

sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 1" "none,none,Activate Task Manager Entry 1"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 2" "none,none,Activate Task Manager Entry 2"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 3" "none,none,Activate Task Manager Entry 3"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 4" "none,none,Activate Task Manager Entry 4"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 5" "none,none,Activate Task Manager Entry 5"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 6" "none,none,Activate Task Manager Entry 6"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 7" "none,none,Activate Task Manager Entry 7"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 8" "none,none,Activate Task Manager Entry 8"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 9" "none,none,Activate Task Manager Entry 9"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 10" "none,none,Activate Task Manager Entry 10"

sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 1" "Meta+1,none,Switch to Desktop 1"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 2" "Meta+2,none,Switch to Desktop 2"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 3" "Meta+3,none,Switch to Desktop 3"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 4" "Meta+4,none,Switch to Desktop 4"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 5" "Meta+5,none,Switch to Desktop 5"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 6" "Meta+6,none,Switch to Desktop 6"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 7" "Meta+7,none,Switch to Desktop 7"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 8" "Meta+8,none,Switch to Desktop 8"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 9" "Meta+9,none,Switch to Desktop 9"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 10" "Meta+0,none,Switch to Desktop 10"

sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 1" "Meta+\!,none,Window to Desktop 1"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 2" "Meta+@,none,Window to Desktop 2"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 3" "Meta+#,none,Window to Desktop 3"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 4" "Meta+$,none,Window to Desktop 4"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 5" "Meta+%,none,Window to Desktop 5"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 6" "Meta+^,none,Window to Desktop 6"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 7" "Meta+&,none,Window to Desktop 7"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 8" "Meta+*,none,Window to Desktop 8"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 9" "Meta+(,none,Window to Desktop 9"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 10" "Meta+),none,Window to Desktop 10"

sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Window Close" "Ctrl+Shift+Q,none,Close Window"

sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Toggle Tiles Editor" "none,none,Toggle Tiles Editor"

sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group org.kde.dolphin.desktop --key "_launch" "none,none,Dolphin"

sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Make Window Fullscreen" "none,none,Make Window Fullscreen"
sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Make Window Fullscreen" "Meta+Shift+F,none,Make Window Fullscreen"

# Disable app launch feedback

sudo -u "${USER}" kwriteconfig5 --file klaunchrc --group BusyCursorSettings --key "Bouncing" --type bool false
sudo -u "${USER}" kwriteconfig5 --file klaunchrc --group FeedbackStyle --key "BusyCursor" --type bool false

# Disable baloo file indexer

sudo -u ${USER} balooctl suspend
sudo -u ${USER} balooctl disable
sudo -u ${USER} balooctl purge

# Remove kwallet

sudo -u "${USER}" kwriteconfig5 --file kwalletrc --group 'Wallet' --key 'Enabled' 'false'
sudo -u "${USER}" kwriteconfig5 --file kwalletrc --group 'Wallet' --key 'First Use' 'false'
sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd5.service
