#!/usr/local/bin/bash

########### UPGRADE SYSTEM ###########

sudo pkg upgrade

########### PACKAGES ###########

sudo pkg install git nnn neovim firefox setsid wget gsed gawk xclip pcmanfm
sudo pkg install fzf exa bottom fd-find bat gitui ripgrep
sudo pkg install nerd-fonts
sudo pkg install py39-pip

########### CONFIGS ###########

mkdir -p ~/local/bin
cp -r ~/setup/scripts/send.sh ~/.local/bin/
chmod +x ~/.local/bin/send.sh

sudo pkg install tree-sitter meson ninja shfmt
pip install neovim
cd ~/.config
mkdir kitty
cd kitty
cp -r ~/setup/configs/nvim/ .
cd

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

rm -rf ~/.config/fish/config.fish
cd ~/.config
cp -r ~/setup/configs/config.fish ~/.config/fish/
cd

########### JELLYFIN SERVER ###########

fetch https://github.com/Thefrank/jellyfin-server-freebsd/releases/download/v10.8.9/jellyfinserver-10.8.9.pkg
sudo pkg install jellyfinserver-10.8.9.pkg
rm -rf jellyfinserver-10.8.9.pkg
sudo sysrc jellyfinserver_enable=TRUE
sudo service jellyfinserver start

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

# Fix resolution

echo "xrandr --output eDP-1 --mode 1920x1080 --scale 1x1" >>~/.xinitrc

# Fix Audio

sudo echo 'hint.hdaa.0.nid33.config="as=2 seq=15"' | sudo tee -a /boot/device.hints >/dev/null
sudo echo 'hint.hdaa.0.nid20.config="as=2 seq=0"' | sudo tee -a /boot/device.hints >/dev/null
