#!/usr/bin/env bash

# CACHE PASSWORD

sudo sed -i '71 a Defaults        timestamp_timeout=30000' /etc/sudoers

# Get Dotfiles

git clone https://github.com/glowfi/setup

# Get DS

sudo xbps-install -Sy github-cli
git clone https://github.com/glowfi/DS

# Core Packages

sudo xbps-install make awk gcc curl wget git xz unzip zip nano vim gptfdisk xtools mtools mlocate ntfs-3g fuse-exfat bash-completion linux-headers gtksourceview4 ffmpeg mesa-vdpau mesa-vaapi
sudo xbps-install autoconf automake bison m4 make libtool flex meson ninja optipng sassc
sudo xbps-install -Sy git xfce4-screenshooter
sudo xbps-install -Sy xdg-utils

# Fonts

sudo xbps-install -Sy nerd-fonts nerd-fonts-ttf
sudo xbps-install -Sy noto-fonts-ttf noto-fonts-ttf noto-fonts-ttf-extra

# Spice Agent

sudo xbps-install -Sy spice-vdagent
sudo ln -s /etc/sv/spice-vdagentd/ /var/service
sudo sv up spice-vdagentd

# Kitty Terminal

sudo xbps-install -Sy kitty
cp -r $HOME/setup/configs/kitty $HOME/.config/

# Fish Shell

sudo xbps-install -Sy fish-shell
fish -c "exit"
cp -r $HOME/setup/configs/config.fish $HOME/.config/fish/
sudo usermod --shell /bin/fish "$USER"
echo "Changed default shell!"

# Python

sudo xbps-install -Sy python3 python3-pip
sudo rm -rf /usr/lib/python3.11/EXTERNALLY-MANAGED

# NodeJS

sudo xbps-install -Sy nodejs

# Docker
sudo xbps-install -Sy docker docker-compose
sudo ln -s /etc/sv/containerd /var/service
sudo ln -s /etc/sv/docker /var/service
sudo sv up containerd
sudo sv up docker
sudo groupadd docker
sudo usermod -aG docker ${USER}
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R

# NixOS 23.05
sudo xbps-install -Sy nix
sudo ln -s /etc/sv/nix-daemon /var/service/
sudo sv up nix-daemon
nix-channel --add https://nixos.org/channels/nixos-22.05 nixpkgs
nix-channel --update

# REPLACEMENTS OF SOME GNU COREUTILS AND SOME OTHER *nix PROGRAMS

sudo xbps-install -Sy exa bat ripgrep fd bottom
sudo xbps-install -Sy bc gum delta tldr duf gping tokei hyperfine

# FZF TERMINAL INTEGRATION

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

# Browser

sudo xbps-install -Sy firefox

######## Firefox ########

rm -rf $HOME/.mozilla/
sudo rm -rf /usr/lib/firefox/distribution

### Policies

sudo mkdir -p /usr/lib/firefox/distribution/
sudo touch /usr/lib/firefox/distribution/policies.json
echo '
{
	"policies": {
		"CaptivePortal": false,
		"DisableFirefoxAccounts": true,
		"DisableFirefoxStudies": true,
		"DisablePocket": true,
		"DisableTelemetry": true,
		"Extensions": {
			"Install": [
				"https://addons.mozilla.org/firefox/downloads/latest/tabliss/latest.xpi",
				"https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi",
				"https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi"
				]
		},
            "FirefoxHome": {
			"Search": true,
			"TopSites": false,
			"SponsoredTopSites": false,
			"Highlights": false,
			"Pocket": false,
			"SponsoredPocket": false,
			"Snippets": false,
			"Locked": false
		},
		"NetworkPrediction": false,
		"OverrideFirstRunPage": "about:home",
		"UserMessaging": {
			"WhatsNew": false,
			"ExtensionRecommendations": false,
			"FeatureRecommendations": false,
			"SkipOnboarding": false
		},
		"NoDefaultBookmarks":true
	}
}' | sudo tee -a /usr/lib/firefox/distribution/policies.json >/dev/null

###### Start Firefox ######

sudo -u "$USER" firefox --headless &
sleep 6
pkill -u "$USER" firefox

###### Arkenfox Profile ######

# Get Default-release Location
findLocation=$(find ~/.mozilla/ | grep -E "default-default" | head -1)

# Go to default-release profile
cd "$findLocation"

# User CSS
mkdir chrome
cd chrome
cd ..

# Get Arkenfox user.js
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js

# Settings
echo -e "\n" >>user.js
echo "// ****** OVERRIDES ******" >>user.js
echo "" >>user.js
echo 'user_pref("keyword.enabled", true);' >>user.js
echo "user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);" >>user.js
echo 'user_pref("general.smoothScroll",                                       true);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.enabled",                    true);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant",  600);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",      650);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         25);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",      2.0);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",     250);' >>user.js
echo 'user_pref("general.smoothScroll.currentVelocityWeighting",              1.0);' >>user.js
echo 'user_pref("general.smoothScroll.stopDecelerationWeighting",             1.0);' >>user.js
echo 'user_pref("mousewheel.default.delta_multiplier_y",                      300);' >>user.js

cd

# INSTALL AND COPY NNN FM SETTINGS

sudo xbps-install -Sy trash-cli tree
sudo xbps-install -Sy nnn

mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
cd
cp -r $HOME/setup/scripts/preview-tui $HOME/.config/nnn/plugins

# CONFIGURING GIT

git config --global user.name -
git config --global user.email -

echo "[core]
    pager = delta --syntax-theme 'gruvbox-dark'

[interactive]
    diffFilter = delta --color-only --features=interactive

[delta]
    features = decorations

[delta \"interactive\"]
    keep-plus-minus-markers = false

[delta \"decorations\"]
    commit-decoration-style = blue ol
    commit-style = raw
    file-style = omit
    hunk-header-decoration-style = blue box
    hunk-header-file-style = red
    hunk-header-line-number-style = \"#067a00\"
    hunk-header-style = file line-number syntax
" >>$HOME/.gitconfig

# Editor

pip install neovim black flake8 beautysh
pip uninstall -y cmake
sudo npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver bash-language-server browser-sync
sudo xbps-install -Sy cmake ninja tree-sitter xclip

sudo xbps-install -Sy fortune-mod
sudo xbps-install -Sy neovim

cp -r $HOME/setup/configs/nvim $HOME/.config

# Extra

pip install xhibit

# DELETE CACHED PASSWORD

sudo sed -i '72d' /etc/sudoers

# Create custom keybindings

xfconf-query -c xfce4-keyboard-shortcuts -n -t 'string' -p "/commands/custom/<Super>t" -s "kitty"
xfconf-query -c xfce4-keyboard-shortcuts -n -t 'string' -p "/commands/custom/<Super>b" -s "firefox"

# Theme

git clone https://github.com/grassmunk/Chicago95
cd Chicago95
./installer.py
cd ..
rm -rf Chicago95
wget "https://i.imgur.com/I4IF27V.jpg" -O "$HOME/Downloads/background.png"
