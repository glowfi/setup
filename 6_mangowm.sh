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

# Window Manager
header "Installing Mango WM"
install "mangowm-git" "yay"

# Core
header "Installing core packages"
install "wl-clipboard" "pac"
install "xdg-user-dirs xdg-desktop-portal xdg-desktop-portal-wlr xdg-utils" "pac"

# Display
header "Installing display configuration packages"
install "wlsunset wlr-randr wdisplays brightnessctl" "pac"

# Audio
header "Installing audio packages"
install "pulsemixer pamixer" "pac"

# Apps
header "Installing application"
install "blueman" "pac"
install "inotify-tools libnotify swaync" "pac"
install "awww swayosd swayimg" "pac"
install "pcmanfm mtpfs gvfs-mtp" "pac"
install "jmtpfs" "yay"
install "zathura zathura-pdf-mupdf" "pac"
install "ark" "pac"
install "grim slurp" "pac"

# Swayosd openrc fix
if [[ "$DISTRO_TYPE" == "artix" ]]; then
	sudo tee /usr/share/dbus-1/system.d/org.erikreider.swayosd.conf >/dev/null <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE busconfig PUBLIC "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
<busconfig>
  <policy user="root">
    <allow own="org.erikreider.swayosd"/>
  </policy>
  <policy context="default">
    <allow send_destination="org.erikreider.swayosd"/>
  </policy>
</busconfig>
EOF

	sudo tee /etc/init.d/swayosd-libinput >/dev/null <<'EOF'
#!/sbin/openrc-run
name="swayosd libinput backend"
command="/usr/bin/swayosd-libinput-backend"
command_background=true
pidfile="/run/swayosd-libinput.pid"
depend() {
	need dbus
}
EOF

	sudo chmod +x /etc/init.d/swayosd-libinput
	sudo rc-update add swayosd-libinput default
	sudo rc-service dbus reload
	sudo rc-service swayosd-libinput start
fi

install_go_tool() {
	local name="$1" repo="$2"
	local dir="/tmp/$name"

	header "Install $name"
	git_clone "$repo" "$dir" 1
	(cd "$dir" && fish -c "go build -o '$dir/$name'")
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

# Mbar
mbar_build_dir="/tmp/mbar"
git_clone "https://github.com/glowfi/mbar" "${mbar_build_dir}" 1
cd "/${mbar_build_dir}"
make
sudo mv mbar /usr/local/bin/
cd

# Theme
header "Installing theme packages and configuring theming"
install "kvantum qt6ct nwg-look" "pac"
install "breeze-icons breeze-gtk breeze" "pac"
install "adwaita-icon-theme adwaita-cursors" "pac"

CONFIG_DIR="$HOME/.dotfiles/configs/theme"
TMP="$(mktemp -d)"
THEMES_DIR="$HOME/.local/share/themes"
ICONS_DIR="$HOME/.local/share/icons"

git clone --depth 1 https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme "$TMP/gtk"
mkdir -p "$THEMES_DIR"
"$TMP/gtk/themes/install.sh" -d "$THEMES_DIR" -l

git clone --depth 1 https://github.com/TheGreatMcPain/gruvbox-material-gtk "$TMP/icons"
mkdir -p "$ICONS_DIR"
cp -r "$TMP/icons/icons/." "$ICONS_DIR/"
gtk-update-icon-cache -f "$ICONS_DIR/Gruvbox-Material-Dark" 2>/dev/null || true

git clone --depth 1 https://github.com/sachnr/gruvbox-kvantum-themes.git "$TMP/kvantum"
mkdir -p "$HOME/.config/Kvantum"
cp -r "$TMP"/kvantum/*Blue*/ "$HOME/.config/Kvantum/" 2>/dev/null ||
	cp -r "$TMP"/kvantum/*/ "$HOME/.config/Kvantum/"

mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0" "$HOME/.config/qt6ct"

cp "$CONFIG_DIR/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
cp "$CONFIG_DIR/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
cp "$CONFIG_DIR/Kvantum/kvantum.kvconfig" "$HOME/.config/Kvantum/kvantum.kvconfig"
cp "$CONFIG_DIR/gtkrc-2.0" "$HOME/.gtkrc-2.0"
cp "$CONFIG_DIR/qt6ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
sudo cp "$CONFIG_DIR/environment" /etc/environment

gsettings set org.gnome.desktop.interface gtk-theme 'Gruvbox-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Gruvbox-Material-Dark'
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors'
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface font-name 'Sans 10'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

cp -r $HOME/.dotfiles/configs/.Xresources $HOME

# Copy mango config
header "Copy mango configuration"
cp -r $HOME/.dotfiles/configs/mango $HOME/.config

# Copy scripts/utitlies for mango
cp -r "$HOME/.dotfiles/scripts/windowshot.sh" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/windowshot.sh"

cp -r "$HOME/.dotfiles/scripts/wall_mango.sh" "$HOME/.local/bin/wall.sh"
chmod +x "$HOME/.local/bin/wall.sh"

cp -r $HOME/.dotfiles/configs/zathura $HOME/.config

# Build bemenu
header "Installing bemenu"
install "bemenu-wayland" "pac"

# Configure mimetype
header "Configuring mimetype"

printf '%s\n' \
	"[Desktop Entry]" \
	"Version=1.0" \
	"Type=Application" \
	"Name=Zathura" \
	"Comment=A minimalistic PDF viewer" \
	"Comment[de]=Ein minimalistischer PDF-Betrachter" \
	"Exec=zathura %%f" \
	"Terminal=false" \
	"Categories=Office;Viewer;" \
	"MimeType=application/pdf;" |
	sudo tee /usr/share/applications/zathura.desktop >/dev/null
xdg-mime default zathura.desktop application/pdf

xdg-mime default swayimg.desktop image/png
xdg-mime default swayimg.desktop image/jpg
xdg-mime default swayimg.desktop image/jpeg

curl -fsSL --retry 5 -o /tmp/default-media-player.sh https://gist.githubusercontent.com/acrisci/b264c4b8e7f93a21c13065d9282dfa4a/raw/8c2b2a57ac74c2fd7c26d02d57203cc746e7d3cd/default-media-player.sh
chmod 0755 /tmp/default-media-player.sh
bash /tmp/default-media-player.sh mpv.desktop
xdg-mime default mpv.desktop image/gif

xdg-mime default pcmanfm.desktop inode/directory

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

# Update user dirs
xdg-user-dirs-update

# Remove kwallet
sudo -u "$USER" kwriteconfig6 --file kwalletrc --group 'Wallet' --key 'Enabled' 'false'
sudo -u "$USER" kwriteconfig6 --file kwalletrc --group 'Wallet' --key 'First Use' 'false'
sudo rm -rf /usr/share/dbus-1/services/org.kde.kwalletd6.service

# Enable services
header "Enabling services"
for svc in swayosd-libinput-backend; do
	if [[ "$DISTRO_TYPE" == "arch" ]]; then
		sudo systemctl enable "$svc"
	# else
	# 	sudo rc-update add "$svc" default
	fi
done

# Login Manager
if [[ "$DISTRO_TYPE" == "arch" ]]; then
	install "ly" "pac"
	sudo systemctl disable getty@tty2.service
	sudo systemctl enable ly@tty2.service
else
	install "ly-openrc" "pac"
	sudo rc-update add ly default
	sudo rc-update del agetty.tty2
fi
sudo sed -i '/^bigclock *=/{h;s/=.*/= en/};${x;/^$/{s//bigclock = en/;H};x}' /etc/ly/config.ini

# Power Management
sudo tee /etc/udev/rules.d/99-power-profile.rules >/dev/null <<'EOF'
SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="/usr/bin/powerprofilesctl set performance"
SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="/usr/bin/powerprofilesctl set balanced"
EOF

sudo sed -i \
	-e 's|^#\?HandleLidSwitch=.*|HandleLidSwitch=suspend|' \
	-e 's|^#\?HandleLidSwitchExternalPower=.*|HandleLidSwitchExternalPower=suspend|' \
	-e 's|^#\?HandleLidSwitchDocked=.*|HandleLidSwitchDocked=ignore|' \
	-e 's|^#\?HandlePowerKey=.*|HandlePowerKey=suspend|' \
	"$LOGIND_CONF"

sudo sed -i \
	-e 's|^PercentageLow=.*|PercentageLow=20|' \
	-e 's|^PercentageCritical=.*|PercentageCritical=10|' \
	-e 's|^PercentageAction=.*|PercentageAction=3|' \
	-e 's|^CriticalPowerAction=.*|CriticalPowerAction=Suspend|' \
	/etc/UPower/UPower.conf

# Lockscreen
install "swayidle" "pac"
pip install terminaltexteffects
cp -r "$HOME/.dotfiles/scripts/screensaver.sh" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/screensaver.sh"
