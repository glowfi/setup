#!/bin/sh

## TAKE INPUT AFTER RESTART

echo "What is your username?"
read uname

echo "Press 1 to install KDE"
echo "Press 2 to install DWM"
read choice

## MAKE SCRIPTS EXECUTABLE

cd

chmod +x ~/setup/3_packages.sh
~/setup/3_packages.sh $uname

chmod +x ~/setup/4_cdx.sh
~/setup/4_cdx.sh

if [[ $choice == "1" ]]
then
    chmod +x ~/setup/5_kde_.sh
    ~/setup/5_kde_.sh
elif [[ $choice == "2" ]]
then
    chmod +x ~/setup/5_wm_.sh
    ~/setup/5_wm_.sh $uname
else
  echo "Wrong choice!"
fi

## CLEANUP

echo "-----------------------------------------------------"
echo "--------------Cleaning up...-------------------------"
echo "-----------------------------------------------------"

yes | sudo pacman -Sc;
yes | yay -Sc;
printf "Cleaned Unused Pacakges!\n";

rm -rf ~/.cache/*;
printf "Cleaned Cache!\n";

sudo pacman -Rns (pacman -Qtdq)  2> /dev/null;
yes | printf "Cleaned Orphans!"

## REFETCHING SETUP

cd
rm -rf setup 
git clone https://github.com/glowfi/setup
