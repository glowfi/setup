#!/bin/sh

# READ ARGUMENT
uname=$1


# CORE PACAKAGES

echo ""
echo "---------------------------------------------------------------------------------"
echo "--------------Installing CORE PACKAGES FOR DWM...--------------------------------"
echo "---------------------------------------------------------------------------------"
echo ""

sudo pacman -S --noconfirm pcmanfm ark sxiv zathura zathura-pdf-poppler flameshot dunst 
sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-xrandr xorg-xsetroot xautolock 
sudo pacman -S --noconfirm pulsemixer pamixer
sudo pacman -S --noconfirm lxrandr brightnessctl picom feh xdg-user-dirs xdg-desktop-portal-kde xdg-utils  
sudo pacman -S --noconfirm mtpfs gvfs-mtp
yay -S --noconfirm jmtpfs 

# APPEARANCE

sudo pacman -S --noconfirm lxappearance breeze-icons breeze-gtk breeze ttf-joypixels
yes | yay -S libxft-bgra

# SETUP DXHD

echo ""
echo "-------------------------------------------------------------------------------"
echo "--------------Installing Hotkey Daemon...--------------------------------------"
echo "-------------------------------------------------------------------------------"
echo ""

yay -S --noconfirm dxhd-bin
cp -r ~/setup/configs/dxhd ~/.config 


echo ""
echo "----------------------------------------------------------------------------------------"
echo "--------------Creating wallpaper and pipewire scripts...--------------------------------"
echo "----------------------------------------------------------------------------------------"
echo ""

# WALLPAPER SCRIPT

touch ~/.wall.sh
echo '#!/bin/bash
while true;
do
    feh --bg-fill "$(find $HOME/wall -type f -name '*.jpg' -o -name '*.png' | shuf -n 1)"
    sleep 900s
done &
' >> ~/.wall.sh


# PIPEWIRE SCRIPT

touch ~/.pw.sh
echo "#!/bin/sh
/usr/bin/pipewire &
/usr/bin/pipewire-pulse &
/usr/bin/pipewire-media-session
" >> ~/.pw.sh

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Creating xinitrc...---------------------------------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

# XINIT SETUP

cp /etc/X11/xinit/xinitrc ~/.xinitrc
sed -i '51,55d' ~/.xinitrc

echo "# Resolution
xrandr --output eDP-1 --mode 1336x768 &

# Picom 
picom -f --experimental-backends --backend glx &

# Hotkey daemon
dxhd -b &

# Pipewire
sh ~/.pw.sh &

# Wallpaper
sh ~/.wall.sh &

# Autolock
xautolock -time 5 -locker slock &

# dwm-bar
~/dwm-bar/dwm_bar.sh &

# Infinte loop
while true;do 
    dwm >/dev/null 2>&1 
done

# DWM Execute
exec dwm
" >> ~/.xinitrc


echo ""
echo "---------------------------------------------------------------------------------------------------"
echo "--------------Installing DWM DMENU SLOCK AND TOPBAR...---------------------------------------------"
echo "---------------------------------------------------------------------------------------------------"
echo ""

# INSTALL DWM

cd ~/setup/configs/dwm-6.2
sudo cp config.def.h config.h
sudo make clean install
cd ..

# INSTALL DEMNU

cd ~/setup/configs/dmenu
sudo make clean install
cd ..

# INSTALL SLOCK

cd ~/setup/configs/slock
new1=static const char *user  = "${uname}";
new2=static const char *group = "${uname}";
sudo sed -i "2s/.*/static const char *user  = "$uname";/" ~/setup/configs/slock/config.def.h
sudo sed -i "3s/.*/static const char *group = "$uname";/" ~/setup/configs/slock/config.def.h
sudo mv ~/setup/configs/slock/slock@.service /etc/systemd/system/slock@.service
sudo cp config.def.h config.h
sudo make clean install
sudo systemctl enable slock@$uname.service
cd ..

# INSTALL TOPBAR

cp -r ~/setup/configs/dwm-bar ~
cd

echo ""
echo "------------------------------------------------------------------------------------------"
echo "--------------Setting default application for filetypes...--------------------------------"
echo "------------------------------------------------------------------------------------------"
echo ""

# UPDATE MIMETYPE

touch ~/zathura.desktop
sudo touch zathura.desktop
cp -r ~/setup/configs/zathura ~/.config

sudo echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Zathura
Comment=A minimalistic PDF viewer
Comment[de]=Ein minimalistischer PDF-Betrachter
Exec=zathura %f
Terminal=false
Categories=Office;Viewer;
MimeType=application/pdf;
" >> ~/zathura.desktop
sudo mv ~/zathura.desktop /usr/share/applications


xdg-mime default sxiv.desktop image/png
xdg-mime default sxiv.desktop image/jpg
xdg-mime default sxiv.desktop image/jpeg
xdg-mime default zathura.desktop application/pdf

