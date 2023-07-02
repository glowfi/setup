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

mkdir -p cd $HOME/.local/share/plank/themes/shade/
cd $HOME/.local/share/plank/themes/shade/
wget https://raw.githubusercontent.com/erikdubois/plankthemes/master/shade/dock.theme
cd

##### MPV #####

wget https://gist.githubusercontent.com/acrisci/b264c4b8e7f93a21c13065d9282dfa4a/raw/8c2b2a57ac74c2fd7c26d02d57203cc746e7d3cd/default-media-player.sh
bash ./default-media-player.sh mpv.desktop
rm -rf default-media-player.sh

mkdir -p .config/mpv/scripts
touch $HOME/.config/mpv/mpv.conf
echo "script-opts-append=ytdl_hook-ytdl_path=yt-dlp" >>$HOME/.config/mpv/mpv.conf

mkdir -p $HOME/.config/mpv/scripts
wget https://github.com/ekisu/mpv-webm/releases/download/latest/webm.lua -P $HOME/.config/mpv/scripts

wget https://github.com/marzzzello/mpv_thumbnail_script/releases/download/0.5.2/mpv_thumbnail_script_client_osc.lua -P $HOME/.config/mpv/scripts
wget https://github.com/marzzzello/mpv_thumbnail_script/releases/download/0.5.2/mpv_thumbnail_script_server.lua -P $HOME/.config/mpv/scripts
echo "osc=no" >>$HOME/.config/mpv/mpv.conf

cd .config/mpv/scripts/
git clone https://github.com/4ndrs/PureMPV
cd

########### Restore Settings ###########

echo "
[com/solus-project/brisk-menu]
dark-theme=false
window-type='classic'

[net/launchpad/plank/docks/dock1]
alignment='center'
auto-pinning=true
current-workspace-only=false
dock-items=['caja-browser.dockitem', 'kitty.dockitem', 'eom.dockitem', 'mpv.dockitem', 'firefox.dockitem', 'matecc.dockitem']
hide-delay=0
hide-mode='intelligent'
icon-size=52
items-alignment='center'
lock-items=false
monitor=''
offset=0
pinned-only=false
pressure-reveal=false
show-dock-item=false
theme='shade'
tooltips-enabled=true
unhide-delay=0
zoom-enabled=false
zoom-percent=150

[org/gnome/evolution-data-server]
migrated=true

[org/mate/caja/window-state]
geometry='800x550+558+261'
maximized=false
start-with-sidebar=true
start-with-status-bar=true
start-with-toolbar=true

[org/mate/desktop/accessibility/keyboard]
bouncekeys-beep-reject=true
bouncekeys-delay=300
bouncekeys-enable=false
enable=false
feature-state-change-beep=false
mousekeys-accel-time=1200
mousekeys-enable=false
mousekeys-init-delay=160
mousekeys-max-speed=750
slowkeys-beep-accept=true
slowkeys-beep-press=true
slowkeys-beep-reject=false
slowkeys-delay=300
slowkeys-enable=false
stickykeys-enable=false
stickykeys-latch-to-lock=true
stickykeys-modifier-beep=true
stickykeys-two-key-off=true
timeout=120
timeout-enable=false
togglekeys-enable=false

[org/mate/desktop/applications/calculator]
exec='mate-calc'

[org/mate/desktop/applications/terminal]
exec='kitty'

[org/mate/desktop/interface]
gtk-color-scheme='topbar_bg_color:#222222\ntopbar_fg_color:#EFEFEF'
gtk-theme='Vimix-Dark'
icon-theme='ePapirus-Dark'

[org/mate/desktop/keybindings/custom0]
action='clipmenu'
binding='<Mod4>e'
name='Clipboard'

[org/mate/desktop/keybindings/custom1]
action='dmenu_run'
binding='<Mod4>p'
name='App Launcher'

[org/mate/desktop/peripherals/mouse]
cursor-theme='Adwaita'

[org/mate/desktop/session]
session-start=1685829561

[org/mate/desktop/sound]
event-sounds=true
input-feedback-sounds=true
theme-name='__no_sounds'

[org/mate/marco/general]
compositing-manager=true
theme='Vimix-Dark'

[org/mate/marco/global-keybindings]
run-command-terminal='<Mod4>t'
switch-to-workspace-1='<Mod4>1'
switch-to-workspace-2='<Mod4>2'
switch-to-workspace-3='<Mod4>3'

[org/mate/marco/window-keybindings]
close='<Primary><Shift>q'
move-to-side-n='<Mod4>Up'
move-to-side-s='<Mod4>Down'
tile-to-side-e='<Mod4>Right'
tile-to-side-w='<Mod4>Left'
toggle-maximized='<Primary><Shift>m'

[org/mate/panel/general]
default-layout='element'
object-id-list=['notification-area', 'clock', 'object-0']
toplevel-id-list=['top']

[org/mate/panel/objects/clock]
applet-iid='ClockAppletFactory::ClockApplet'
locked=true
object-type='applet'
panel-right-stick=true
position=10
toplevel-id='top'

[org/mate/panel/objects/clock/prefs]
custom-format=''
format='24-hour'

[org/mate/panel/objects/notification-area]
applet-iid='NotificationAreaAppletFactory::NotificationArea'
locked=true
object-type='applet'
panel-right-stick=true
position=20
toplevel-id='top'

[org/mate/panel/objects/object-0]
object-type='menu-bar'
panel-right-stick=false
position=0
toplevel-id='top'

[org/mate/panel/objects/window-list/prefs]
group-windows='never'

[org/mate/panel/toplevels/top]
expand=true
orientation='top'
screen=0
size=24

[org/mate/power-manager]
action-critical-battery='hibernate'
button-lid-ac='suspend'
button-lid-battery='suspend'
button-power='interactive'
button-suspend='suspend'

[org/mate/settings-daemon/plugins/media-keys]
www='<Mod4>b'
" >settings.conf

dconf load / <settings.conf
rm settings.conf

##### Clipboard Support #####

echo "## Clipmenu
clipmenud &
" >>$HOME/.xprofile

######## CONFIGURING GIT #######

git config --global user.name -
git config --global user.email -

########### CONFIGS ###########

mkdir -p $HOME/local/bin

# NNN Config
pip install trash-cli
mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
cd
cp -r $HOME/setup/scripts/preview-tui $HOME/.config/nnn/plugins

# Null Server Script
cp -r $HOME/setup/scripts/send.sh $HOME/.local/bin/
cd $HOME/.local/bin/
rep=$(fish -c 'printf "#!/usr/local/bin/bash"')
gawk -v line="1" -v text="$rep" '{
  if (NR == line) {
    print text
  } else {
    print $0
  }
}' send.sh >output_file.txt
mv output_file.txt send.sh
chmod +x $HOME/.local/bin/send.sh
cd

# Neovim Config
sudo pkg install -y tree-sitter ninja shfmt
sudo npm update -g npm
sudo install npm@latest -g
pip install neovim black flake8
sudo npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver browser-sync
cd $HOME/.config
mkdir nvim
cd nvim
cp -r $HOME/setup/configs/nvim/ .
gsed -i '34,40d' $HOME/.config/nvim/lua/core/dashboard.lua
cd

# Kitty Config
cd $HOME/.config
mkdir kitty
cd kitty
cp -r $HOME/setup/configs/kitty/ .
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
rm -rf $HOME/.config/fish/config.fish
cd $HOME/.config
cp -r $HOME/setup/configs/config.fish $HOME/.config/fish/
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

findLocation=$(find $HOME/.mozilla/firefox/ | grep -E "default-release" | head -1)

# Activate Settings

cd "$findLocation"
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js
gsed -i "s/$original/$required/g" user.js
cd

########### Fix resolution ###########

echo "xrandr --output eDP-1 --mode 1920x1080 --scale 1x1" >>$HOME/.xprofile

########### Fix Audio ###########

sudo echo 'hint.hdaa.0.nid33.config="as=2 seq=15"' | sudo tee -a /boot/device.hints >/dev/null
sudo echo 'hint.hdaa.0.nid20.config="as=2 seq=0"' | sudo tee -a /boot/device.hints >/dev/null

########### Enable SSH ###########

# sudo echo 'sshd_enable="YES"' | sudo tee -a /etc/rc.conf >/dev/null
# sudo /etc/rc.d/sshd start
