#!/bin/sh

########### UPGRADE SYSTEM ###########

sudo pkg upgrade

########### PACKAGES ###########

sudo pkg install -y git nnn neovim firefox kitty
sudo pkg install -y setsid wget gsed gawk bash
sudo pkg install -y xclip
sudo pkg install -y fzf exa bottom fd-find bat gitui ripgrep
sudo pkg install -y nerd-fonts
sudo pkg install -y py39-pip
sudo pkg install -y node npm
sudo pkg install -y devel/gh
sudo pkg install -y papirus-icon-theme
sudo pkg install -y mpv aria2

###### PLANK THEME ######

mkdir -p cd ~/.local/share/plank/themes/shade/
cd ~/.local/share/plank/themes/shade/
wget https://raw.githubusercontent.com/erikdubois/plankthemes/master/shade/dock.theme
cd

########### Restore Keyboard Shortcuts ###########

# dconf dump /org/mate/desktop/keybindings/ > dconf-mate-desktop-keybindings.conf
# dconf dump /org/mate/marco/window-keybindings/ > dconf-mate-marco-keybindings.conf

echo "[/]
close='<Primary><Shift>q'
move-to-side-n='<Mod4>Up'
move-to-side-s='<Mod4>Down'
tile-to-side-e='<Mod4>Right'
tile-to-side-w='<Mod4>Left'
toggle-maximized='<Primary><Shift>m'" >dconf-mate-marco-keybindings.conf

echo "[custom0]
action='clipmenu'
binding='<Mod4>e'
name='Clipboard'

[custom1]
action='dmenu_run'
binding='<Mod4>p'
name='App Launcher'" >dconf-mate-desktop-keybindings.conf

dconf load /org/mate/desktop/keybindings/ <dconf-mate-desktop-keybindings.conf
dconf load /org/mate/marco/window-keybindings/ <dconf-mate-marco-keybindings.conf

rm dconf-mate-marco-keybindings.conf dconf-mate-desktop-keybindings.conf

##### Clipboard Support #####

echo "## Clipmenu
clipmenud &
" >>~/.xprofile

######## CONFIGURING GIT #######

git config --global user.name -
git config --global user.email -

########### CONFIGS ###########

mkdir -p ~/local/bin

# NNN Config
pip install trash-cli
mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
cd
cp -r ~/setup/scripts/preview-tui ~/.config/nnn/plugins

# Null Server Script
cp -r ~/setup/scripts/send.sh ~/.local/bin/
cd ~/.local/bin/
rep=$(fish -c 'printf "#!/usr/local/bin/bash"')
gawk -v line="1" -v text="$rep" '{
  if (NR == line) {
    print text
  } else {
    print $0
  }
}' send.sh >output_file.txt
mv output_file.txt send.sh
chmod +x ~/.local/bin/send.sh
cd

# Neovim Config
sudo pkg install -y tree-sitter ninja shfmt
sudo npm update -g npm
sudo install npm@latest -g
pip install neovim black flake8
sudo npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver browser-sync
cd ~/.config
mkdir nvim
cd nvim
cp -r ~/setup/configs/nvim/ .
gsed -i '34,40d' ~/.config/nvim/lua/core/dashboard.lua
cd

# Kitty Config
cd ~/.config
mkdir kitty
cd kitty
cp -r ~/setup/configs/kitty/ .
rep=$(echo "shell /usr/local/bin/fish")
gawk -v line="14" -v text="$rep" '{
  if (NR == line) {
    print text
  } else {
    print $0
  }
}' kitty.conf >output_file.txt

mv output_file.txt kitty.conf
cd

# Fish Config
rm -rf ~/.config/fish/config.fish
cd ~/.config
cp -r ~/setup/configs/config.fish ~/.config/fish/
cd

########### JELLYFIN SERVER ###########

# fetch https://github.com/Thefrank/jellyfin-server-freebsd/releases/download/v10.8.9/jellyfinserver-10.8.9.pkg
# sudo pkg install -y jellyfinserver-10.8.9.pkg
# sudo pkg install -y libva-utils libva-intel-media-driver
# cd /usr/local/bin
# fish -c'sudo touch lffmpeg'
# sudo fish -c 'printf "#!/bin/sh\n"' | sudo tee -a /usr/local/bin/lffmpeg >/dev/null
# sudo fish -c 'printf "ffmpeg -hwaccel vaapi "\$@""' | sudo tee -a /usr/local/bin/lffmpeg >/dev/null
# sudo chmod +x lffmpeg
# rm -rf jellyfinserver-10.8.9.pkg
# sudo sysrc jellyfinserver_enable=TRUE
# sudo service jellyfinserver start
# cd

########### FIREFOX HARDENING ###########

setsid firefox
sleep 3
killall firefox

# Settings

original=$(echo 'user_pref("keyword.enabled", false);')
required=$(echo 'user_pref("keyword.enabled", true);')

# Get Default-release Location

findLocation=$(find ~/.mozilla/firefox/ | grep -E "default-release" | head -1)

# Activate Settings

cd "$findLocation"
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js
gsed -i "s/$original/$required/g" user.js
cd

########### Fix resolution ###########

echo "xrandr --output eDP-1 --mode 1920x1080 --scale 1x1" >>~/.xinitrc

########### Fix Audio ###########

sudo echo 'hint.hdaa.0.nid33.config="as=2 seq=15"' | sudo tee -a /boot/device.hints >/dev/null
sudo echo 'hint.hdaa.0.nid20.config="as=2 seq=0"' | sudo tee -a /boot/device.hints >/dev/null

########### Enable SSH ###########

# sudo echo 'sshd_enable="YES"' | sudo tee -a /etc/rc.conf >/dev/null
# sudo /etc/rc.d/sshd start
