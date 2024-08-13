#!/usr/bin/env bash

### Main packages
sudo dnf makecache
sudo dnf copr enable atim/bottom -y
sudo dnf install gitui -y
sudo dnf install exa bat ripgrep fd-find bottom sad git-delta tldr duf arai2c -y
sudo dnf install python3-pip kitty neovim fish fortune-mod -y
sudo dnf install cmake ninja-build tree-sitter-cli xclip shfmt meson -y
sudo dnf -y groupinstall "Development Tools"
sudo dnf -y groupinstall "X Software Development"

# FZF
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
yes | ~/.fzf/install

# Git repo
git clone --depth=1 https://github.com/glowfi/setup

# Kitty
cp -r $HOME/setup/configs/kitty $HOME/.config/

# Fish
fish -c "exit"
cp -r $HOME/setup/configs/config.fish $HOME/.config/fish/
sudo usermod --shell /bin/fish "$USER"
echo "Changed default shell!"

# Font
sudo mkdir /usr/share/fonts/FantasqueSansMono
cd /usr/share/fonts/FantasqueSansMono
sudo wget 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FantasqueSansMono.zip'
sudo unzip "FantasqueSansMono.zip"
sudo fc-cache -fv
cd

# Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
rustup default stable

# Golang
cd ~/.local/bin
curl https://go.dev/dl/ | grep -e linux | head -2 | grep -e href | awk -F href '{print $2}' | tr -d "=" | tr -d ">" | xargs -I {} wget https://go.dev{} -O go.tar.gz
tar -xzf go.tar.gz
rm -rf go.tar.gz
mv ./go ./golang
cd
go install golang.org/x/tools/gopls@latest
go install github.com/segmentio/golines@latest
go install golang.org/x/tools/cmd/goimports@latest
go install mvdan.cc/gofumpt@latest

# Python
pip install xhibit

# Bun
curl -fsSL https://bun.sh/install | bash

# Nvim
pip install neovim black flake8
sudo npm i -g neovim typescript pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver bash-language-server @tailwindcss/language-server browser-sync graphql-language-service-cli
pip uninstall -y cmake

cd $HOME
mkdir $HOME/.config
cp -r $HOME/setup/configs/nvim $HOME/.config
cp -r $HOME/setup/configs/nvim/.vsnip/ $HOME

# tgpt
curl -sSL https://raw.githubusercontent.com/aandrew-me/tgpt/main/install | bash -s /usr/local/bin

# nnn
sudo dnf install trash-cli tree -y
aria2c "https://buzzheavier.com/f/GUKeKB1pAAA" -o nnn
chmod +x ./nnn
mv ./nnn ~/.local/bin/

mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
cd
cp -r $HOME/setup/scripts/misc/preview-tui $HOME/.config/nnn/plugins

# Tiling
sudo dnf install gnome-shell-extension-pop-shell xprop

# Add to fish config
echo 'alias spac="dnf list --available | cut -f 1 -d '\'' '\'' | sort -Vk1 | uniq | fzf -m --cycle | xargs -ro sudo dnf install"' >>~/.config/fish/config.fish
echo 'alias pacu="dnf list installed | cut -f 1 -d '\'' '\'' | sort -Vk1 | uniq | fzf -m --cycle | xargs -ro sudo dnf remove"' >>~/.config/fish/config.fish

# Set default browser and text editor
xdg-mime default nvim.desktop text/plain
xdg-settings set default-web-browser brave-browser.desktop

######## Librewolf ########

sudo rm -rf /usr/share/librewolf/
rm -rf $HOME/.librewolf/
curl -fsSL https://rpm.librewolf.net/librewolf-repo.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
sudo dnf install librewolf -y
secProfileName=$(echo "Tmp")

###### Start Librewolf ######

sudo -u "$USER" librewolf --headless &
sleep 6
pkill -u "$USER" librewolf

### Add Extensions

extensions=("https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi" "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi")

for i in "${extensions[@]}"; do
	c=$(cat /usr/share/librewolf/distribution/policies.json | grep -n "Install" | head -1 | awk -F":" '{print $1}' | xargs)
	sudo sed -i "${c} a \"${i}\"," /usr/share/librewolf/distribution/policies.json
done

###### Arkenfox Profile 1 [clear hist on exit] ######

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

# Brave

sudo dnf install dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser

browser_loc=$(echo "/opt/brave.com/brave")

sudo rm -rf /opt/brave.com/brave
rm -rf $HOME/.config/BraveSoftware/

type=$(echo "brave")
typeFolder=$(echo "Brave-Browser")
secProfileName=$(echo "Tmp")

sudo mkdir -p "${browser_loc}/policies/managed/"
sudo touch "${browser_loc}/policies/managed/brave-policy.json"
cat $HOME/setup/configs/brave/policy.json | sudo tee -a "${browser_loc}/policies/managed/brave-policy.json" >/dev/null

### Create Default Profile

sudo -u "$USER" "${type}-browser" --headless=new &
mkdir -p "/home/$USER/.config/BraveSoftware/$typeFolder/Default"
sleep 3
pkill -u "$USER" "${type}-browser"
rm -rf "$HOME/.config/BraveSoftware/$typeFolder/SingletonLock"

### Create Secondary Profile
sudo -u "$USER" "${type}-browser" --headless=new --profile-directory="$secProfileName" &
mkdir -p "/home/$USER/.config/BraveSoftware/$typeFolder/$secProfileName"
sleep 3
pkill -u "$USER" "${type}-browser"
rm -rf "$HOME/.config/BraveSoftware/$typeFolder/SingletonLock"

### Copy Settings
sleep 3
touch "$HOME/.config/BraveSoftware/$typeFolder/Default/Preferences"
cat $HOME/setup/configs/brave/settings.json >"$HOME/.config/BraveSoftware/$typeFolder/Default/Preferences"

sleep 3
touch "$HOME/.config/BraveSoftware/$typeFolder/$secProfileName/Preferences"
cat $HOME/setup/configs/brave/settings.json >"$HOME/.config/BraveSoftware/$typeFolder/$secProfileName/Preferences"

# AFTER SETUP
# fixed no fo workspace
# set clsoe window,toggle fullscreen,switch to wotrkpace to right/left,move window one place to left workpsace
# filemanger terminal browser
