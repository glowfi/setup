#!/usr/bin/env bash

# Synchronize

pacman -Scc && pacman -Syy

sudo pacman -Syyy

# CACHE PASSWORD

sudo sed -i '71 a Defaults        timestamp_timeout=30000' /etc/sudoers

# Get Dotfiles

cd
git clone https://github.com/glowfi/setup

# Enable archlinux

sudo pacman -S --noconfirm artix-archlinux-support
sudo tee -a /etc/pacman.conf <<EOF

[extra]
Include = /etc/pacman.d/mirrorlist-arch

[community]
Include = /etc/pacman.d/mirrorlist-arch
EOF
sudo pacman-key --populate archlinux

# Install base packages

sudo pacman -S --noconfirm base-devel
sudo pacman -S --noconfirm exa bat ripgrep fd bottom sad bc gum git-delta tldr duf gping tokei hyperfine fzf
sudo pacman -S --noconfirm fish fzf git kitty vim

# Python

sudo pacman -S --noconfirm python-pip
pyloc=$(sudo fd . /usr/lib/ --type f --max-depth 2 | grep "EXTERNALLY-MANAGED" | head -1)
sudo rm -rf "$pyloc"
pip intall xhibit

# nodeJS

sudo pacman -S --noconfirm nodejs npm

# Install YAY

git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin/
makepkg -si --noconfirm
cd $HOME
rm -rf yay-bin

# Install Fonts

sudo pacman -S --noconfirm ttf-fantasque-sans-mono noto-fonts-emoji noto-fonts
yay -S --noconfirm ttf-fantasque-nerd ttf-ms-fonts ttf-vista-fonts

# Install spice-vdagent

sudo pacman -S --noconfirm spice-vdagent-openrc
sudo rc-update add spice-vdagent
sudo rc-service spice-vdagent start

# INSTALL AND COPY NNN FM SETTINGS

sudo pacman -S --noconfirm trash-cli tree
git clone https://github.com/jarun/nnn
cd nnn
sudo make O_NERD=1 install
cd ..
rm -rf nnn

mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
cd
cp -r $HOME/setup/scripts/preview-tui $HOME/.config/nnn/plugins

# COPY BASH VIM settings TO HOME

cp -r $HOME/setup/configs/.bashrc $HOME
cp -r $HOME/setup/configs/.vimrc $HOME
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
rm -rf ble.sh

# COPY BASH VIM settings TO ROOT

sudo cp $HOME/.bashrc /root/
sudo cp $HOME/.vimrc /root/
sudo su -c "git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git;make -C ble.sh install PREFIX=~/.local;rm -rf ble.sh"

# COPY FISH SHELL SETTINGS

fish -c "exit"
cp -r $HOME/setup/configs/config.fish $HOME/.config/fish/

# COPY KITTY SETTINGS

cp -r $HOME/setup/configs/kitty $HOME/.config/

# CHANGE DEFAULT SHELL

sudo usermod --shell /bin/fish "$USER"
echo "Changed default shell!"

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

pip install neovim black flake8
sudo npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver bash-language-server browser-sync
pip uninstall -y cmake

sudo pacman -S --noconfirm cmake ninja tree-sitter tree-sitter-cli xclip shfmt meson fortune-mod
sudo pacman -S --noconfirm neovim
cp -r ~/setup/configs/nvim ~/.config

# Get DS

sudo pacman -S --noconfirm github-cli
git clone https://github.com/glowfi/DS

# Browser

yay -S --noconfirm librewolf-bin
rm -rf $HOME/.librewolf/

###### Start Librewolf ######

sudo -u "$USER" librewolf --headless &
sleep 6
pkill -u "$USER" librewolf

### Copy a script to start librewolf without volume auto adjust
mkdir -p $HOME/.local/bin/
cp -r $HOME/setup/scripts/libw $HOME/.local/bin/
chmod +x $HOME/.local/bin/libw

### Add Extensions

extensions=("https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi" "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi" "https://addons.mozilla.org/firefox/downloads/latest/libredirect/latest.xpi")

for i in "${extensions[@]}"; do
	c=$(cat /usr/lib/librewolf/distribution/policies.json | grep -n "Install" | head -1 | awk -F":" '{print $1}' | xargs)
	sudo sed -i "${c} a \"${i}\"," /usr/lib/librewolf/distribution/policies.json
done

###### Arkenfox Profile ######

# Get Default-release Location
findLocation=$(find ~/.librewolf/ | grep -E "default-default" | head -1)

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

### Download Libredirect

cd $HOME/Downloads
wget "https://0x0.st/Hfw2.0.json" -O "libredirect-settings.json"
ver=$(echo "2.8.0")
wget "https://github.com/libredirect/browser_extension/releases/download/v$ver/libredirect-$ver.crx"
cd

# DELETE CACHED PASSWORD

sudo sed -i '72d' /etc/sudoers
