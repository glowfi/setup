#!/usr/bin/env bash

###### Add Tiling ######

# Download Krohnkite

cd
git clone https://github.com/esjeon/krohnkite
cd krohnkite
make install
mkdir -p $HOME/.local/share/kservices5/
ln -s $HOME/.local/share/kwin/scripts/krohnkite/metadata.desktop $HOME/.local/share/kservices5/krohnkite.desktop
cd ..
rm -rf krohnkite

# Creating Breezerc to hide title bars

touch $HOME/.config/breezerc
sudo -u "${USER}" kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key BorderSize 0
sudo -u "${USER}" kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key Enabled false
sudo -u "${USER}" kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key ExceptionPattern .\*
sudo -u "${USER}" kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key ExceptionType 0
sudo -u "${USER}" kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key HideTitleBar true
sudo -u "${USER}" kwriteconfig5 --file breezerc --group "Windeco Exception 0" --key Mask 16

# Tiling Shortcuts

sudo -u "${USER}" kwriteconfig5 --file kglobalshortcutsrc --group kwin --key "Krohnkite: Cycle Layout" "Meta+ctrl+\.,none,Krohnkite: Cycle Layout"

###### Post Setup Steps ######

# Add Fullscreen shortcut
# Set Default Terminal
# Enable and configure Tiling
# Enable Night Color
# Disable Screenlocking and configure screenlocker
# Set Mouse acc profile to adaptive
