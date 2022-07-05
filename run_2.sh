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

echo ""
echo "Press 1 to install KDE"
echo "Press 2 to install DWM"
read choice

if [[ "$choice" == "1" || "$choice" == "2" ]]; then

	## MAKE SCRIPTS EXECUTABLE
	cd

	chmod +x ~/setup/3_packages.sh
	~/setup/3_packages.sh $uname

	chmod +x ~/setup/4_cdx.sh
	~/setup/4_cdx.sh

	if [[ $choice == "1" ]]; then
		clear
		chmod +x ~/setup/5_kde_.sh
		~/setup/5_kde_.sh
	elif [[ $choice == "2" ]]; then
		clear
		chmod +x ~/setup/5_dwm_.sh
		~/setup/5_dwm_.sh $uname
	fi

else
	printf $'\e[31mWrong choice entered! Run the script again.\e[0m\n'
	exit 0
fi

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

## REFETCHING SETUP

echo ""
echo "-----------------------------------------------------------"
echo "--------------Refetching Setup ...-------------------------"
echo "-----------------------------------------------------------"
echo ""

cd
rm -rf setup
git clone https://github.com/glowfi/setup

## END

echo ""
echo "   ▄▄   ▀▀█    ▀▀█           ▄▄▄▄                          ▄   "
echo "   ██     █      █           █   ▀▄  ▄▄▄   ▄ ▄▄    ▄▄▄     █   "
echo "  █  █    █      █           █    █ █▀ ▀█  █▀  █  █▀  █    █   "
echo "  █▄▄█    █      █           █    █ █   █  █   █  █▀▀▀▀    ▀   "
echo " █    █   ▀▄▄    ▀▄▄         █▄▄▄▀  ▀█▄█▀  █   █  ▀█▄▄▀    █   "
echo ""
