#!/usr/bin/env bash

# Core Packages

sudo xbps-install -Sy wget curl make awk gcc
sudo xbps-install -Sy git

# Fonts
sudo xbps-install nerd-fonts nerd-fonts-ttf

# Spice Agent

sudo xbps-install -Sy spice-vdagent
sudo ln -s /etc/sv/spice-vdagentd/ /var/service
sudo sv up spice-vdagentd

# Config

git clone https://github.com/glowfi/setup

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

# NodeJS

sudo xbps-install -Sy nodejs

# Rust utils

sudo xbps-install -Sy exa bat ripgrep fd bottom bc gum delta tldr duf gping tokei hyperfine

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
}'| sudo tee -a /usr/lib/firefox/distribution/policies.json >/dev/null


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
echo -e "\n" >> user.js
echo "// ****** OVERRIDES ******" >> user.js
echo "" >> user.js
echo 'user_pref("keyword.enabled", true);' >> user.js
echo "user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);" >> user.js
echo 'user_pref("general.smoothScroll",                                       true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.enabled",                    true);'>> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant",  600);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",      650);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         25);'  >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",      2.0);' >> user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",     250);' >> user.js
echo 'user_pref("general.smoothScroll.currentVelocityWeighting",              1.0);' >> user.js
echo 'user_pref("general.smoothScroll.stopDecelerationWeighting",             1.0);' >> user.js
echo 'user_pref("mousewheel.default.delta_multiplier_y",                      300);' >> user.js

cd


# INSTALL AND COPY NNN FM SETTINGS

sudo xbps-install -Sy trash-cli tree
sudo xbps-install -Sy nnn

mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
cd
cp -r $HOME/setup/scripts/preview-tui $HOME/.config/nnn/plugins

git clone https://github.com/mwh/dragon
cd dragon
make clean install
cd ..
rm -rf dragon

# Editor

pip install neovim black flake8 beautysh
pip uninstall -y cmake
sudo npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver bash-language-server browser-sync
sudo xbps-install -Sy cmake ninja tree-sitter xclip

sudo xbps-install -Sy fortune-mod
sudo xbps-install -Sy neovim

cp -r $HOME/setup/configs/nvim $HOME/.config
nvim -c PackerSync
nvim -c PackerSync
nvim -c PackerSync

# Copy DS
git clone https://github.com/glowfi/DS
