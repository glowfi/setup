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
sudo rm -rf /usr/local/bin/bemenu /usr/local/bin/bemenu-app/ /usr/local/bin/bemenu-run
cd $HOME/.dotfiles/configs/bemenu-app
$HOME/.dotfiles/configs/bemenu-app/help.sh wayland
sudo mv $HOME/.dotfiles/configs/bemenu-app/ /usr/local/bin/
sudo mv /usr/local/bin/bemenu-app/bemenu /usr/local/bin/
sudo mv /usr/local/bin/bemenu-app/bemenu-run /usr/local/bin/
cd

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

# Copy plasma specific utilites/settings
cp -r "$HOME/.dotfiles/scripts/wall.sh" "$HOME/.local/bin"

# Theme
header "Installing theme packages and configuring theming"
install "breeze breeze-gtk kde-gtk-config kdecoration" "pac"
cp -r $HOME/.dotfiles/configs/.Xresources $HOME

sudo -u "$USER" kwriteconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
printf '[Theme]\nCurrent=breeze\n' | sudo tee /etc/sddm.conf.d/theme.conf

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
sed -i 's|^ConfigFile=.*|ConfigFile=configs/ken.conf|' "${sddm_theme_dir}/install.sh"
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
