#!/bin/sh

clear

#### RUN THIS SCRIPT AFTER RESTART

echo ""
echo "-------------------------------------------------------------"
echo "--------------DE/WM INSTALLATION...--------------------------"
echo "-------------------------------------------------------------"
echo ""

## GET THE NAME OF CURRENTLY LOGGED IN USER
uname=$(echo "$USER")

echo -e "Choose DE/WM to Install :"
choice=$(gum choose "DWM" "KDE")

## MAKE SCRIPTS EXECUTABLE
cd

chmod +x ~/setup/3_0_packages.sh
~/setup/3_0_packages.sh

chmod +x ~/setup/3_1_browser.sh
~/setup/3_1_browser.sh

chmod +x ~/setup/4_cdx.sh
~/setup/4_cdx.sh

if [[ $choice == "KDE" ]]; then
	clear
	chmod +x ~/setup/5_kde_.sh
	~/setup/5_kde_.sh
elif [[ $choice == "DWM" ]]; then
	clear
	chmod +x ~/setup/5_dwm_.sh
	~/setup/5_dwm_.sh $uname
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
