#!/bin/bash

# Setup
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/helpers/pkg_installer.sh"
source "${SCRIPT_DIR}/helpers/header.sh"
source "${SCRIPT_DIR}/helpers/git_clone.sh"
source "${SCRIPT_DIR}/helpers/detect_init.sh"

INIT_TYPE=$(detect_init)
DISTRO_TYPE="arch"
if [[ "$INIT_TYPE" != "systemD" ]]; then
	DISTRO_TYPE="artix"
fi

# Xorg packages
install "xorg-server xorg-xrandr xorg-xdpyinfo xorg-xprop xorg-xwininfo xdotool xclip wmctrl plasma-x11-session" "pac"

# Wayland packages
install "wayland wayland-protocols plasma-wayland-protocols xorg-xwayland qt6-wayland egl-wayland wl-clipboard"

# Core
header "Installing core packages"
install "plasma-desktop plasma-workspace plasma-workspace-wallpapers plasma-nm plasma-pa qt6-tools" "pac"
install "kwrited kwin kgamma kinfocenter kscreen systemsettings libnotify konqueror"
if [[ "$DISTRO_TYPE" = "arch" ]]; then
	install "sddm sddm-kcm" "pac"
else
	install "sddm-openrc sddm-kcm" "pac"
fi
install "bluedevil powerdevil xdg-desktop-portal-kde" "pac"

# Apps
install "dolphin ark gwenview okular spectacle" "pac"
install "pulsemixer pamixer" "pac"
install "brightnessctl" "pac"

install_go_tool() {
	local name="$1" repo="$2"
	local dir="/tmp/$name"

	header "Install $name"
	git_clone "$repo" "$dir" 1
	(cd "$dir" && go build -o "$dir/$name" .)
	sudo install -m755 "$dir/$name" /usr/local/bin/
	rm -rf "$dir"

	mkdir -p "$HOME/.config/$name"
	mv "$HOME/.dotfiles/configs/$name/config_mango.yaml" "$HOME/.config/$name/config.yaml"
}

# Autostart
sudo usermod -aG input "$USER"
install_go_tool autost https://github.com/glowfi/autost

# Hotkey daemon
install_go_tool ghkd https://github.com/glowfi/ghkd

# Build bemenu
header "Installing bemenu"
install "bemenu-wayland" "pac"

# Update mimetype
header "Update mimetype"
curl -fsSL --retry 5 -o /tmp/default-media-player.sh https://gist.githubusercontent.com/acrisci/b264c4b8e7f93a21c13065d9282dfa4a/raw/8c2b2a57ac74c2fd7c26d02d57203cc746e7d3cd/default-media-player.sh
chmod 0755 /tmp/default-media-player.sh
bash /tmp/default-media-player.sh mpv.desktop
xdg-mime default mpv.desktop image/gif

xdg-mime default dolphin.desktop inode/directory
xdg-settings set default-web-browser brave-browser.desktop
xdg-mime default brave-browser.desktop x-scheme-handler/http
xdg-mime default brave-browser.desktop x-scheme-handler/https

# Set neovim as default app
for m in \
	text/plain text/x-c text/x-c++src text/x-chdr text/x-c++hdr \
	text/x-python text/x-script.python application/x-shellscript \
	text/x-go text/x-rust text/x-lua text/x-java text/x-ruby \
	text/javascript application/javascript application/json \
	text/x-makefile text/x-cmake text/markdown text/x-readme \
	application/x-yaml text/x-toml application/toml application/xml \
	text/html text/css; do
	xdg-mime default nvim.desktop "$m"
done

# Copy plasma specific utilites/settings
cp -r "$HOME/.dotfiles/scripts/wall.sh" "$HOME/.local/bin"

# Theme
header "Installing theme packages and configuring theming"
install "breeze breeze-gtk kde-gtk-config kdecoration" "pac"
cp -r $HOME/.dotfiles/configs/.Xresources $HOME

sudo -u "$USER" kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
getReq=$(cat /usr/lib/sddm/sddm.conf.d/default.conf | grep -n "Current=" | head -1 | xargs)
getLineNumber=$(echo "$getReq" | cut -d":" -f1)
rep="Current=breeze"
sudo sed -i "${getLineNumber}s/.*/${rep}/" /usr/lib/sddm/sddm.conf.d/default.conf

# Plasma optimization
header "Adding plasma optimization"
balooctl6 disable || true
sudo -u "$USER" kwriteconfig6 --file kwalletrc --group Wallet --key Enabled false
sudo -u "$USER" kwriteconfig6 --file kwalletrc --group Wallet --key "First Use" false
sudo rm -f /usr/share/dbus-1/services/org.kde.kwalletd6.service

# Krohnkite
header "Installing Krohnkite"
krohnkite_build_dir="/tmp/Krohnkite"
install "go-task" "pac"
git_clone "https://codeberg.org/anametologin/Krohnkite" "${krohnkite_build_dir}" 1
cd "${krohnkite_build_dir}" && go-task install
cd
rm -rf "${krohnkite_build_dir}"

# Plasma Video Wallpaper
install "git gcc cmake extra-cmake-modules libplasma qt6-multimedia qt6-multimedia-ffmpeg" "pac"
git_clone "https://github.com/luisbocanegra/plasma-smart-video-wallpaper-reborn" "$HOME/Downloads/plasma-smart-video-wallpaper-reborn" 1

# SDDM Theme
header "Theming SDDM"
sddm_theme_dir="$HOME/Downloads/SilentSDDM"
git_clone "https://github.com/uiriansan/SilentSDDM" "${sddm_theme_dir}" 1
sed -i 's|^ConfigFile=.*|ConfigFile=configs/ken.conf|' "${sddm_theme_dir}/metadata.desktop"
cd "${sddm_theme_dir}" && sudo ./install.sh
cd

# Update user dirs
xdg-user-dirs-update

header "Enabling services"
for svc in sddm; do
	if [[ "$DISTRO_TYPE" == "arch" ]]; then
		sudo systemctl enable "$svc"
	else
		sudo rc-update add "$svc" default
	fi
done

# Configure virtual desktop
kwriteconfig6 --file kwinrc --group Desktops --key Number 6
kwriteconfig6 --file kwinrc --group Desktops --key Rows 1
for i in 1 2 3 4 5 6; do
	kwriteconfig6 --file kwinrc --group Desktops --key "Name_$i" "$i"
done

# Night Light: always on
kwriteconfig6 --file kwinrc --group NightColor --key Active true
kwriteconfig6 --file kwinrc --group NightColor --key Mode Constant
kwriteconfig6 --file kwinrc --group NightColor --key NightTemperature 4500

# Kitty Setup dolphin
header "Setingup kitty in dolphin"

# 3a. "Open Kitty Here" right-click menu
MENU_DIR="$HOME/.local/share/kio/servicemenus"
mkdir -p "$MENU_DIR"
cat >"$MENU_DIR/open-kitty-here.desktop" <<'EOF'
[Desktop Entry]
Type=Service
MimeType=inode/directory;
Actions=openKitty;
X-KDE-Priority=TopLevel
 
[Desktop Action openKitty]
Name=Open Kitty Here
Icon=kitty
Exec=kitty --directory %f
EOF
chmod +x "$MENU_DIR/open-kitty-here.desktop" # required since KF 5.85

# 3b. kitty as the system-wide default terminal
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication kitty

# 3c. F4 in Dolphin launches kitty (instead of the embedded panel)
UI_DIR="$HOME/.local/share/kxmlgui5/dolphin"
mkdir -p "$UI_DIR"
cat >"$UI_DIR/dolphinui.rc" <<'EOF'
<?xml version="1.0"?>
<gui name="dolphin" version="1">
 <ActionProperties scheme="Default">
  <Action name="open_terminal" shortcut="F4"/>
  <Action name="show_terminal_panel" shortcut=""/>
 </ActionProperties>
</gui>
EOF

# Resource monitor
header "Installing Resources Monitor plasmoid"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --depth 1 \
	https://github.com/orblazer/plasma-applet-resources-monitor.git "$TMP"

PLUGIN_ID="$(jq -r '.KPlugin.Id' "$TMP/package/metadata.json")"
if kpackagetool6 --type Plasma/Applet --show "$PLUGIN_ID" &>/dev/null; then
	kpackagetool6 --type Plasma/Applet --upgrade "$TMP/package"
else
	kpackagetool6 --type Plasma/Applet --install "$TMP/package"
fi
