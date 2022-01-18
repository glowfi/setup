#!/usr/bin/env bash

# Script Directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Config file checking
CONFIG_FILE=$SCRIPT_DIR/setup.conf
if [ ! -f $CONFIG_FILE ]; then # check if file exists
	touch -f $CONFIG_FILE         # create file if not exists
fi

# Logo
logo() {

	f=3 b=4
	for j in f b; do
		for i in {0..7}; do
			printf -v $j$i %b "\e[${!j}${i}m"
		done
	done
	for i in {0..7}; do
		printf -v fbright$i %b "\e[9${i}m"
	done
	bld=$'\e[1m'
	rst=$'\e[0m'
	inv=$'\e[7m'

	cat <<EOF

 $fbright3  ▄███████▄                $fbright1  ▄██████▄    $fbright2  ▄██████▄    $fbright4  ▄██████▄    $fbright5  ▄██████▄    $fbright6  ▄██████▄    
 $fbright3▄█████████▀▀               $fbright1▄$fbright7█▀█$fbright1██$fbright7█▀█$fbright1██▄  $fbright2▄█$fbright7█ █$fbright2██$fbright7█ █$fbright2█▄  $fbright4▄█$fbright7█ █$fbright4██$fbright7█ █$fbright4█▄  $fbright5▄█$fbright7█ █$fbright5██$fbright7█ █$fbright5█▄  $fbright6▄██$fbright7█▀█$fbright6██$fbright7█▀█$fbright6▄
 $fbright3███████▀      $fbright7▄▄  ▄▄  ▄▄   $fbright1█$fbright7▄▄█$fbright1██$fbright7▄▄█$fbright1███  $fbright2██$fbright7███$fbright2██$fbright7███$fbright2██  $fbright4██$fbright7███$fbright4██$fbright7███$fbright4██  $fbright5██$fbright7███$fbright5██$fbright7███$fbright5██  $fbright6███$fbright7█▄▄$fbright6██$fbright7█▄▄$fbright6█
 $fbright3███████▄      $fbright7▀▀  ▀▀  ▀▀   $fbright1████████████  $fbright2████████████  $fbright4████████████  $fbright5████████████  $fbright6████████████  
 $fbright3▀█████████▄▄               $fbright1██▀██▀▀██▀██  $fbright2██▀██▀▀██▀██  $fbright4██▀██▀▀██▀██  $fbright5██▀██▀▀██▀██  $fbright6██▀██▀▀██▀██
 $fbright3  ▀███████▀                $fbright1▀   ▀  ▀   ▀  $fbright2▀   ▀  ▀   ▀  $fbright4▀   ▀  ▀   ▀  $fbright5▀   ▀  ▀   ▀  $fbright6▀   ▀  ▀   ▀
 $rst
EOF

	echo "   ▄▄                 █              ▄▄▄▄           ▄                 "
	echo "   ██    ▄ ▄▄   ▄▄▄   █ ▄▄          █▀   ▀  ▄▄▄   ▄▄█▄▄  ▄   ▄  ▄▄▄▄  "
	echo "  █  █   █▀  ▀ █▀  ▀  █▀  █         ▀█▄▄▄  █▀  █    █    █   █  █▀ ▀█ "
	echo "  █▄▄█   █     █      █   █             ▀█ █▀▀▀▀    █    █   █  █   █ "
	echo " █    █  █     ▀█▄▄▀  █   █         ▀▄▄▄█▀ ▀█▄▄▀    ▀▄▄  ▀▄▄▀█  ██▄█▀ "
	echo "                                                                █     "
	echo "                                                                ▀     "

}

# Handle File system

filesystem() {

	echo ""
	echo "---------------------------------------------------"
	echo "------- Choose filesytem...------------------------"
	echo "---------------------------------------------------"
	echo ""

	echo -ne "
    Please Select your file system for both boot and root
    Type 1 for btrfs
    Type 2 for ext4
    Type 0 to exit
"
	read FS

	if [[ "$FS" = "1" ]]; then
		echo "btrfs" >>"$CONFIG_FILE"
	elif [[ "$FS" = "2" ]]; then
		echo "ext4" >>"$CONFIG_FILE"
	elif [[ "$FS" = "0" ]]; then
	    rm -rf "$CONFIG_FILE"
		exit
	else
		echo "Wrong option entered!"
		filesystem
	fi
}

# Handle Timezone

timezone() {

	echo ""
	echo "---------------------------------------------------"
	echo "------- Choose Timezone...-------------------------"
	echo "---------------------------------------------------"
	echo ""

	time_zone="$(curl --fail https://ipapi.co/timezone)"
	echo -ne "System detected your timezone to be '$time_zone' \n"
	echo -ne "Is this correct? yes/no:"
	read answer
	case $answer in
	y | Y | yes | Yes | YES)
		echo "$time_zone" >>"$CONFIG_FILE"
		;;
	n | N | no | NO | No)
		echo "Please enter your desired timezone e.g. Europe/London :"
		read new_timezone
		echo "$time_zone" >>"$CONFIG_FILE"
		;;
	*)
		echo "Wrong option. Try again"
		timezone
		;;
	esac
}

# Handle Keymap

keymap() {

	echo ""
	echo "---------------------------------------------------------"
	echo "------- Choose keyboard layout...------------------------"
	echo "---------------------------------------------------------"
	echo ""

	echo -ne "
Please select key board layout from this list
    -by
    -ca
    -cf
    -cz
    -de
    -dk
    -es
    -et
    -fa
    -fi
    -fr
    -gr
    -hu
    -il
    -it
    -lt
    -lv
    -mk
    -nl
    -no
    -pl
    -ro
    -ru
    -sg
    -ua
    -uk
    -us

"
	read -p "Your key boards layout:" keymap
	echo "$keymap" >>"$CONFIG_FILE"
}

# Handle drive type

drivetype() {

	echo ""
	echo "----------------------------------------------------"
	echo "------- Choose drive type...------------------------"
	echo "----------------------------------------------------"
	echo ""

	echo -ne "
Is this an ssd? yes/no:
"
	read ssd_drive

	case $ssd_drive in
	y | Y | yes | Yes | YES)
		echo "ssd" >>"$CONFIG_FILE"
		;;
	n | N | no | NO | No)
		echo "non-ssd" >>"$CONFIG_FILE"
		;;
	*)
		echo "Wrong option. Try again"
		drivessd
		;;
	esac
}

# Handle diskpart

diskpart() {

	echo ""
	echo "------------------------------------------------------"
	echo "------- Choose diskpartiton...------------------------"
	echo "------------------------------------------------------"
	echo ""

	lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print NR,"/dev/"$2" - "$3}'
	echo -ne "
    ------------------------------------------------------------------------
        THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK             
        Please make sure you know what you are doing because         
        after formating your disk there is no way to get data back      
    ------------------------------------------------------------------------

Please enter full path to disk: (example /dev/sda):
"
	read option
	echo "$option" >>setup.conf
}

# Handle userinfo

userinfo() {

	echo ""
	echo "-----------------------------------------------------"
	echo "------- Enter user details...------------------------"
	echo "-----------------------------------------------------"
	echo ""

	echo ""
	echo "What would be the username?"
	read uname
	echo "$uname" >>"$CONFIG_FILE"

	echo "What would be the fullname of the user?"
	read fname
	echo "$fname" >>"$CONFIG_FILE"

	echo ""
	echo "What would be the password for $uname account?"
	read -s passu1
	echo "Type password for $uname account again"
	read -s passu2
	if [[ "$passu1" == "$passu2" ]]; then
		upass=$passu2
		echo "$upass" >>"$CONFIG_FILE"
	else
		echo "Password do not match.Try running the script again!"
		rm -rf "$CONFIG_FILE"
		exit 0
	fi

	echo ""
	echo "What would be the password for root account?"
	read -s passr1
	echo "Type password for root account again"
	read -s passr2
	if [[ "$passr1" == "$passr2" ]]; then
		rpass=$passr2
		echo "$rpass" >>"$CONFIG_FILE"
	else
		echo "Password do not match.Try running the script again!"
		rm -rf "$CONFIG_FILE"
		exit 0
	fi

	echo ""
	read -rep "Please enter your hostname: " nameofmachine
	echo "$nameofmachine" >>"$CONFIG_FILE"
}

de_wm() {

	echo ""
	echo "-------------------------------------------------------------"
	echo "--------------DE/WM INSTALLATION...--------------------------"
	echo "-------------------------------------------------------------"
	echo ""

	echo ""
	echo "Type 1 to install KDE"
	echo "Type 2 to install DWM"
	read de_wm_

	case $de_wm_ in
	1)
		echo "kde" >>"$CONFIG_FILE"
		;;
	2)
		echo "dwm" >>"$CONFIG_FILE"
		;;
	*)
		echo "Wrong option. Try again"
		de_wm
		;;
	esac

}

logo
filesystem
timezone
keymap
drivetype
diskpart
userinfo
de_wm
