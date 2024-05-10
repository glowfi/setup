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

# Plasma core PACKAGES

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------Installing CORE PACKAGES FOR KDE...--------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

install "plasma-desktop plasma-workspace plasma-nm plasma-pa qt6-tools" "pac"

install "breeze breeze-gtk kde-gtk-config kdecoration" "pac"

install "powerdevil xdg-desktop-portal-kde" "pac"

install "kwrited kwin kgamma kinfocenter kscreen systemsettings sddm sddm-kcm libnotify konqueror" "pac"

install "redshift" "pac"

# CORE PACKAGES

# ===================== XORG Dependent ===================================
install "xorg-server" "pac"
install "xorg-xrandr" "pac"
install "xautolock" "pac"
# ===================== END Dependent ====================================

### Other Core
install "wmctrl" "pac"
install "dolphin ark zathura zathura-pdf-mupdf" "pac"
install "pulsemixer pamixer" "pac"
install "brightnessctl" "pac"

# ===================== XORG Dependent ===================================

# Install nsxiv and setup nsxiv key-handler

install "nsxiv-git" "yay"
mkdir -p $HOME/.config/nsxiv/exec
cp -r $HOME/setup/configs/nsxiv/key-handler $HOME/.config/nsxiv/exec

# Install Launcher-menu

sudo rm -rf /usr/local/bin/bemenu /usr/local/bin/bemenu-app/ /usr/local/bin/bemenu-run 
cd $HOME/setup/configs/bemenu-app/
./help.sh x11
cd ..
sudo mv ./bemenu-app/ /usr/local/bin/
sudo mv /usr/local/bin/bemenu-app/bemenu /usr/local/bin/
sudo mv /usr/local/bin/bemenu-app/bemenu-run /usr/local/bin/
cd

# Install clipmenu

install "clipmenu" "pac";sudo pacman -Rdd dmenu

# ===================== END Dependent ====================================

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
cp -r $HOME/setup/storage/misc/* $HOME/.misc/

# ===================== XORG Dependent ===================================

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Creating xprofile...--------------------------------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

if [[ "$initType" != "systemD" ]]; then
    pipeStr="artix-pipewire-loader &"
else
    pipeStr="systemctl --user start pipewire.service pipewire.socket wireplumber.service pipewire-pulse.service pipewire-pulse.socket pipewire-session-manager.service"
fi

# XPROFILE SETUP

touch $HOME/.xprofile

echo "# Hotkey daemon
dxhd -b &

# Pipewire
${pipeStr}
"'
# Wallpaper
sh $HOME/.local/bin/wall.sh &

# Bluelight Filter
redshift -P -O 4500K &

# Clipboard
clipmenud &

# Autolock
xautolock -time 10 -locker $HOME/.local/bin/screenlocker &

# Kill Useless Process at startup
~/.local/bin/uselesskill.sh &' >>$HOME/.xprofile

### System related scripts
cp -r ~/setup/scripts/system/uselesskill.sh ~/.local/bin/
chmod +x ~/.local/bin/uselesskill.sh

# ===================== END Dependent ====================================

# ENABLE SDDM

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------ENABLE LOGIN MANAGER SDDM...---------------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

# Enable
if [[ "$initType" != "systemD" ]]; then
    sudo rc-update add sddm
else 
    sudo systemctl enable sddm
fi

# Set SDDM theme
getReq=$(cat /usr/lib/sddm/sddm.conf.d/default.conf | grep -n "Current=" | head -1 | xargs)
getLineNumber=$(echo "$getReq" | cut -d":" -f1)
rep="Current=breeze"
sudo sed -i "${getLineNumber}s/.*/${rep}/" /usr/lib/sddm/sddm.conf.d/default.conf

# ======================================================= Can Be Deleted for minimal install =======================================================

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

# ======================================================= END ======================================================================================


# ===================== XORG Dependent ===================================

# Copy Xresources

cp -r $HOME/setup/configs/.Xresources $HOME

# ===================== END Dependent ====================================

# REGISTER KITTY IN DOLPHIN

echo ""
echo "--------------------------------------------------------------------------------"
echo "--------------Register Kitty in Dolphin...--------------------------------------"
echo "--------------------------------------------------------------------------------"
echo ""

mkdir -p $HOME/.local/share/kservices6
cp -r $HOME/setup/configs/plasma/kittyhere.desktop $HOME/.local/share/kservices6

# ===================== XORG Dependent ===================================

# SETUP dxhd

echo ""
echo "-------------------------------------------------------------------------------"
echo "--------------Installing Hotkey Daemon...--------------------------------------"
echo "-------------------------------------------------------------------------------"
echo ""


klone "https://github.com/dakyskye/dxhd.git"
cd dxhd
fish -c 'sudo make install'
cd ..
rm -rf dxhd
mkdir -p $HOME/.config/dxhd
mv $HOME/setup/configs/dxhd/dxhd_kde.sh $HOME/.config/dxhd
mv $HOME/.config/dxhd/dxhd_kde.sh $HOME/.config/dxhd/dxhd.sh

# ===================== END Dependent ====================================

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

# ===================== XORG Dependent ===================================

xdg-mime default nsxiv.desktop image/png
xdg-mime default nsxiv.desktop image/jpg
xdg-mime default nsxiv.desktop image/jpeg

# ===================== END Dependent ====================================


wget https://gist.githubusercontent.com/acrisci/b264c4b8e7f93a21c13065d9282dfa4a/raw/8c2b2a57ac74c2fd7c26d02d57203cc746e7d3cd/default-media-player.sh
bash ./default-media-player.sh mpv.desktop
rm -rf default-media-player.sh
xdg-mime default mpv.desktop image/gif

xdg-mime default dolphin.desktop inode/directory

xdg-settings set default-web-browser brave-browser.desktop

echo "Done seting default application!"
echo ""

echo ""
echo "-----------------------------------------------------------------"
echo "--------------Configuring KDE Plasma...--------------------------"
echo "-----------------------------------------------------------------"
echo ""


### Plasma UI Settings

# Set Plasma theme

sudo -u "$USER" kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage "org.kde.breezedark.desktop"

# Disable splash screen

sudo -u "$USER" kwriteconfig6 --file ksplashrc --group KSplash --key Engine "none"
sudo -u "$USER" kwriteconfig6 --file ksplashrc --group KSplash --key Theme "none"

# Enable 9 desktops

for i in {1..9}
do
    sudo -u "$USER" kwriteconfig6 --file kwinrc --group Desktops --key "Name_${i}" "Desktop ${i}"
    sudo -u "$USER" kwriteconfig6 --file kwinrc --group Desktops --key Number "${i}"
    sudo -u "$USER" kwriteconfig6 --file kwinrc --group Desktops --key Rows "1"
done

# Add command output widget

klone "https://github.com/aricaldeira/plasma-applet-commandoutput"
cd plasma-applet-commandoutput
install "kpackage" "pac"
./build6
./install6
cd ..
rm -rf plasma-applet-commandoutput

# Use KDE file picker in GTK applications

sudo tee -a /etc/environment << EOF

# KDE file picker
GTK_USE_PORTAL=1

# ===================== XORG Dependent ===================================

# Clipmenu
CM_LAUNCHER=bemenu

# ===================== END Dependent ====================================

EOF

# Restore Settings

cp -r $HOME/setup/configs/plasma/plasmashellrc ~/.config/
cp -r $HOME/setup/configs/plasma/plasma-org.kde.plasma.desktop-appletsrc ~/.config/

### Shortcuts

sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "Switch Power Profile" "none,none,Switch Power Profile"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "Dolphin" "none,none,Dolphin"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "Make Window Fullscreen" "none,none,Make Window Fullscreen"


sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 1" "none,none,Activate Task Manager Entry 1"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 2" "none,none,Activate Task Manager Entry 2"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 3" "none,none,Activate Task Manager Entry 3"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 4" "none,none,Activate Task Manager Entry 4"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 5" "none,none,Activate Task Manager Entry 5"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 6" "none,none,Activate Task Manager Entry 6"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 7" "none,none,Activate Task Manager Entry 7"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 8" "none,none,Activate Task Manager Entry 8"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 9" "none,none,Activate Task Manager Entry 9"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group plasmashell --key "activate task manager entry 10" "none,none,Activate Task Manager Entry 10"

sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 1" "Meta+1,none,Switch to Desktop 1"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 2" "Meta+2,none,Switch to Desktop 2"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 3" "Meta+3,none,Switch to Desktop 3"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 4" "Meta+4,none,Switch to Desktop 4"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 5" "Meta+5,none,Switch to Desktop 5"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 6" "Meta+6,none,Switch to Desktop 6"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 7" "Meta+7,none,Switch to Desktop 7"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 8" "Meta+8,none,Switch to Desktop 8"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 9" "Meta+9,none,Switch to Desktop 9"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Switch to Desktop 10" "Meta+0,none,Switch to Desktop 10"

sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 1" "Meta+\!,none,Window to Desktop 1"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 2" "Meta+@,none,Window to Desktop 2"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 3" "Meta+#,none,Window to Desktop 3"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 4" "Meta+$,none,Window to Desktop 4"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 5" "Meta+%,none,Window to Desktop 5"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 6" "Meta+^,none,Window to Desktop 6"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 7" "Meta+&,none,Window to Desktop 7"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 8" "Meta+*,none,Window to Desktop 8"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 9" "Meta+(,none,Window to Desktop 9"
sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window to Desktop 10" "Meta+),none,Window to Desktop 10"

sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Window Close" "Ctrl+Shift+Q,none,Close Window"

sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Toggle Tiles Editor" "none,none,Toggle Tiles Editor"

sudo -u "$USER" kwriteconfig6 --file kglobalshortcutsrc --group org.kde.dolphin.desktop --key "_launch" "none,none,Dolphin"

# Disable app launch feedback

sudo -u "$USER" kwriteconfig6 --file klaunchrc --group BusyCursorSettings --key "Bouncing" --type bool false
sudo -u "$USER" kwriteconfig6 --file klaunchrc --group FeedbackStyle --key "BusyCursor" --type bool false

# Disable baloo file indexer

sudo -u "$USER" balooctl6 suspend
sudo -u "$USER" balooctl6 disable
sudo -u "$USER" balooctl6 purge

# Add Tiling support

# ===================== XORG Dependent ===================================

cp -r $HOME/setup/configs/plasma/cortile $HOME/.config/
cd $HOME/.config/cortile/
set cortile_ver (curl "https://github.com/leukipp/cortile/releases" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | head -1|cut -d"/" -f6|tr -d "v"|xargs)
set var1 (echo "https://github.com/leukipp/cortile/releases/download/v$cortile_ver/cortile_$cortile_ver")
set var2 (echo "_linux_amd64.tar.gz")
set link (string join "" "$var1" "$var2")
wget "$link" -O "cortile.tar.gz"
tar -xzvf ./cortile.tar.gz;rm cortile.tar.gz;rm README.md;rm LICENSE
cd

# ===================== END Dependent ====================================

# Remove kwallet

sudo -u "$USER" kwriteconfig6 --file kwalletrc --group 'Wallet' --key 'Enabled' 'false'
sudo -u "$USER" kwriteconfig6 --file kwalletrc --group 'Wallet' --key 'First Use' 'false'
sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd6.service
