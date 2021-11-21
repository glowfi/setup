#!/bin/sh
cd
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes/
sudo ./install.sh -b -t tela
cd ..
rm -rf grub2-themes
