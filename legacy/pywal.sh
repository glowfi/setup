# DWM INSTALL
wal -i ~/setup/pacman.png
mkdir -p ~/wall
cp -r ~/setup/pacman.png ~/wall

sed -i "21s/.*/#include \"\/home\/"$USER"\/.cache\/wal\/colors-wal-dwm.h\"/" ~/setup/configs/dwm-6.2/config.h

# SCRIPT
feh --bg-fill "$(find ~/wall -type f | shuf -n 1)"
cd
cat .fehbg | tail -1 | awk '{print $NF}' | awk -F"/" '{print $5}' | tr -d "'" | xargs -I {} wal -s -q -t --backend haishoku -i ~/wall/{}
sed -i '9,11d' ~/.cache/wal/colors-wal-dwm.h
sed -i '14d' ~/.cache/wal/colors-wal-dwm.h
cd ~/.config/dwm-6.2/
make clean
make
xdotool key super+shift+q

# PYWAL
sudo pacman -S --noconfirm python-pywal
fish -c "pip install haishoku;exit"
