#!/bin/bash

### Install Dependencies
sudo pacman -S --noconfirm cmake gcc libgl libegl fontconfig spice-protocol make nettle pkgconf binutils libxi libxinerama libxss libxcursor libxpresent libxkbcommon wayland-protocols ttf-dejavu libsamplerate

### Add frame buffer
sudo tee -a /etc/tmpfiles.d/10-looking-glass.conf <<EOF
# Type Path               Mode UID  GID Age Argument

f /dev/shm/looking-glass 0660 $USER kvm -
EOF

### Build LookingGlass
cd ~/Downloads
git clone --recursive https://github.com/gnif/LookingGlass.git
cd LookingGlass
mkdir client/build
cd client/build
cmake ../
make

### Run
# ~/Downloads/LookingGlass/client/build/looking-glass-client
