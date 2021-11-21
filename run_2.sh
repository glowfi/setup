#!/bin/sh

cd

chmod +x ~/setup/2_after_pacstrap.sh
~/setup/2_after_pacstrap.sh 

chmod +x ~/setup/3_packages.sh
~/setup/3_packages.sh

chmod +x ~/setup/4_cdx.sh
~/setup/4_cdx.sh

chmod +x ~/setup/5_wm_.sh
~/setup/5_wm_.sh

echo "-----------------------------------------------------"
echo "--------------Cleaning up...-------------------------"
echo "-----------------------------------------------------"

sudo rm -rf /install

cd
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes/
sudo ./install.sh -b -t tela
cd ..
rm -rf grub2-themes
