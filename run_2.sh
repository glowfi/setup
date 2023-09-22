#!/bin/sh

echo ""
echo "-------------------------------------------------------------"
echo "--------------Installing Dependency ....---------------------"
echo "------------------------------------------------------------ "
echo ""

echo ""
sudo pacman -Syyy --noconfirm gum
clear

echo ""
echo "-------------------------------------------------------------"
echo "--------------DE/WM INSTALLATION...--------------------------"
echo "-------------------------------------------------------------"
echo ""

## GET THE NAME OF CURRENTLY LOGGED IN USER
uname=$(echo "$USER")

echo -e "Want a minimal setup :"
isMinimal=$(gum choose "No" "Yes")

clear

echo -e "Choose DE/WM to Install :"
choice=$(gum choose "DWM" "KDE")

## MAKE SCRIPTS EXECUTABLE
cd

if [[ "$isMinimal" == "Yes" ]]; then
	chmod +x ~/setup/create_minimal.sh
	~/setup/create_minimal.sh
fi

chmod +x ~/setup/3_0_packages.sh
~/setup/3_0_packages.sh

chmod +x ~/setup/3_1_browser.sh
~/setup/3_1_browser.sh

chmod +x ~/setup/4_cdx.sh
~/setup/4_cdx.sh

if [[ $choice == "KDE" ]]; then
	clear
	chmod +x ~/setup/5_kde.sh
	~/setup/5_kde.sh
elif [[ $choice == "DWM" ]]; then
	clear
	chmod +x ~/setup/5_dwm.sh
	~/setup/5_dwm.sh $uname
fi

## REFETCHING SETUP

echo ""
echo "-----------------------------------------------------------"
echo "--------------Refetching Setup ...-------------------------"
echo "-----------------------------------------------------------"
echo ""

cd
if [ -f "$HOME/setup/err.txt" ]; then
	cp -r "$HOME/setup/err.txt" "$HOME/Downloads/"
fi

rm -rf setup
git clone https://github.com/glowfi/setup

chmod +x ~/setup/3_2_performance_security.sh
~/setup/3_2_performance_security.sh

## Regenerate GRUB and initramfs

sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo mkinitcpio -p linux-zen

## CLEANUP

echo ""
echo "-----------------------------------------------------"
echo "--------------Cleaning up...-------------------------"
echo "-----------------------------------------------------"
echo ""

yes | sudo pacman -Sc
yes | yay -Sc
printf "Cleaned Unused Pacakges!\n"

sudo rm -rf ~/.cache/*
printf "Cleaned Cache!\n"

sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null
yes | printf "Cleaned Orphans!"

## DELETE CACHED PASSWORD
sudo sed -i '72d' /etc/sudoers

## END

echo ""
echo "   ▄▄   ▀▀█    ▀▀█           ▄▄▄▄                          ▄   "
echo "   ██     █      █           █   ▀▄  ▄▄▄   ▄ ▄▄    ▄▄▄     █   "
echo "  █  █    █      █           █    █ █▀ ▀█  █▀  █  █▀  █    █   "
echo "  █▄▄█    █      █           █    █ █   █  █   █  █▀▀▀▀    ▀   "
echo " █    █   ▀▄▄    ▀▄▄         █▄▄▄▀  ▀█▄█▀  █   █  ▀█▄▄▀    █   "
echo ""
