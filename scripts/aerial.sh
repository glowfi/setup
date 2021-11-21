#!/bin/sh

# INSTALL DEPENDENCIES
sudo pacman -S --noconfirm gst-libav phonon-qt5-gstreamer gst-plugins-good qt5-quickcontrols qt5-graphicaleffects qt5-multimedia

# LOCKSCREEN THEME
mkdir -p ~/.local/share/plasma/wallpapers/
git clone https://github.com/halverneus/org.kde.video
mv org.kde.video ~/.local/share/plasma/wallpapers/
git clone https://github.com/3ximus/aerial-sddm-theme
cp -r aerial-sddm-theme/playlists ~
rm -rf aerial-sddm-theme

# ADDED TO CLIPBOARD
sed 's:^#\(.*\)$:\1:g' ~/install/scripts/krohnkite.sh | tail -3 | xclip
nvim -c ".+57" ~/.local/share/plasma/wallpapers/org.kde.video/contents/ui/main.qml

# for (var k = 0; k < Math.ceil(Math.random() * 10) ; k++) {
#     playlist.shuffle()
# }
