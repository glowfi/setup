#!/bin/bash

# Setup
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/helpers/pkg_installer.sh"
source "${SCRIPT_DIR}/helpers/detect_init.sh"
source "${SCRIPT_DIR}/helpers/header.sh"
source "${SCRIPT_DIR}/helpers/git_clone.sh"

INIT_TYPE=$(detect_init)
DISTRO_TYPE="arch"
if [[ "$INIT_TYPE" != "systemD" ]]; then
	DISTRO_TYPE="artix"
fi

# Install AUR Helper
header "Installing AUR helper"
aur_helper_dir="/tmp/yay-bin"
git_clone "https://aur.archlinux.org/yay-bin.git" "${aur_helper_dir}" 1
cd "${aur_helper_dir}"
makepkg -si --noconfirm
cd
rm -rf "${aur_helper_dir}"

# Core packages, fonts
header "Installing core packages"
install "zip unzip unrar p7zip lzop ouch man-db fish kitty jq aria2" "pac"

header "Installing fonts"
install "ttf-fantasque-sans-mono noto-fonts noto-fonts-emoji" "pac"
install "ttf-fantasque-nerd ttf-joypixels ttf-ms-fonts ttf-vista-fonts" "yay"

# Audio
header "Installing audio packages"

if [[ "$DISTRO_TYPE" == "arch" ]]; then
	install "alsa-utils alsa-plugins pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber" "pac"
else
	install "alsa-utils-openrc alsa-plugins pipewire-openrc pipewire-alsa pipewire-pulse-openrc pipewire-jack wireplumber-openrc" "pac"
fi

install "bluez bluez-utils" "pac"
install "easyeffects lsp-plugins" "pac"
mkdir -p "${HOME}/.config/easyeffects/output"
curl -fL --retry 5 -o /tmp/easyeffects-install.sh \
	https://raw.githubusercontent.com/JackHack96/PulseEffects-Presets/master/install.sh
chmod 0755 /tmp/easyeffects-install.sh
echo | bash /tmp/easyeffects-install.sh
rm -f /tmp/easyeffects-install.sh

if [[ "$DISTRO_TYPE" == "arch" ]]; then
	for svc in pipewire wireplumber pipewire-pulse; do
		systemctl --user enable --now "$svc"
	done
else
	for svc in pipewire pipewire-pulse wireplumber; do
		rc-update --user add "$svc" default
	done
fi

# Video / Image
header "Installing video packages"
install "ffmpeg yt-dlp mujs mpv" "pac"

header "Installing image tools"
install "imagemagick ffmpegthumbnailer" "pac"

header "Setting up GIMP with PhotoGIMP"
install "gimp" "pac"
gimp_conf="${HOME}/.config/GIMP/3.0"
rm -rf "$gimp_conf"
mkdir -p "$gimp_conf"
git_clone https://github.com/Diolinux/PhotoGIMP "${gimp_conf}/PhotoGIMP" 1
cp -r "${gimp_conf}/PhotoGIMP/.config/GIMP/3.0/." "$gimp_conf/"
rm -rf "${gimp_conf}/PhotoGIMP" "${gimp_conf}/filters" "${gimp_conf}/plug-ins" "${gimp_conf}/splashes"

header "Installing video apps"
install "kdenlive obs-studio" "pac"

# Android Utilities
header "Installing android utilities"
install "android-tools scrcpy mediainfo perl-image-exiftool inotify-tools libnotify gum" "pac"
install "kdeconnect" "pac"

# Document editing/Writing apps
header "Installing Document editing/Writing apps"
install "onlyoffice-bin" "yay"
install "tectonic" "pac"
install "rnote" "pac"

# Terminal tomfoolery
header "Installing terminal fun packages"
install "fortune-mod lolcat cmatrix asciiquarium cowsay figlet sl" "pac"

figlet_dir="/tmp/figlet-fonts"
git_clone "https://github.com/xero/figlet-fonts" "${figlet_dir}" 1
sudo mkdir -p /usr/share/figlet/fonts
sudo cp -r /tmp/figlet-fonts/. /usr/share/figlet/fonts/
rm -rf "${figlet_dir}"

tty_clock_dir="/tmp/tty-clock"
git_clone "https://github.com/xorg62/tty-clock" "${tty_clock_dir}" 1
sudo make -C "${tty_clock_dir}" clean install
rm -rf "${tty_clock_dir}"

pipes_dir="/tmp/pipes"
git_clone "https://github.com/pipeseroni/pipes.sh" "${pipes_dir}" 1
sudo make -C "${pipes_dir}" clean install
rm -rf "${pipes_dir}"

# NNN
header "Installing nnn"
install "trash-cli tree" "pac"

git_clone https://github.com/jarun/nnn /tmp/nnn 1
(cd /tmp/nnn && sudo make O_NERD=1 install)
rm -rf /tmp/nnn

plugin_dir="${HOME}/.config/nnn/plugins"
mkdir -p "$plugin_dir"

if [[ ! -f "${plugin_dir}/autojump" ]]; then
	(cd "$plugin_dir" && curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh)
fi

# Pacman-static
header "Downloading pacman-static"
mkdir -p "${HOME}/.local/bin"
curl -fL --retry 5 -o "${HOME}/.local/bin/pacman-static" \
	https://pkgbuild.com/~morganamilo/pacman-static/x86_64/bin/pacman-static
chmod 0755 "${HOME}/.local/bin/pacman-static"

# Configure shell
header "Cloning dotfiles"
dotfile_dst="${HOME}/.dotfiles"
if [[ -d "$dotfile_dst" ]]; then
	git -C "$dotfile_dst" pull
else
	git_clone https://github.com/glowfi/dotfiles.git "$dotfile_dst" 1
	cd "$dotfile_dst"
	git checkout mango
	cd
fi

header "Setting up fish config"
mkdir -p "${HOME}/.config/fish"
cp -r "${HOME}/.dotfiles/configs/fish/" "${HOME}/.config"

header "Setting up shell rc files"
for f in .bashrc .inputrc .vimrc; do
	cp "${HOME}/.dotfiles/configs/${f}" "${HOME}/${f}"
done

for f in .bashrc .inputrc .vimrc; do
	sudo cp "${HOME}/${f}" "/root/${f}"
done

header "Changing default shell to fish"
sudo usermod -s /usr/bin/fish "$(whoami)"

# Kitty config
header "Setting up kitty config"
mkdir -p "${HOME}/.config/kitty"
cp -r "${HOME}/.dotfiles/configs/kitty" "${HOME}/.config"
