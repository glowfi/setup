#!/usr/bin/env bash

# Script Directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Get Init Type
DETECT_INIT_SCRIPT="$SCRIPT_DIR/detectInit.sh"
initType=$(bash "${DETECT_INIT_SCRIPT}")

# Source Logo
source "${SCRIPT_DIR}/logo.sh"

# Config file checking
CONFIG_FILE=$SCRIPT_DIR/setup.conf
if [ ! -f $CONFIG_FILE ]; then # check if file exists
	touch -f $CONFIG_FILE         # create file if not exists
fi

# Install dependency

installDependency() {

	echo ""
	echo "-------------------------------------------------------------"
	echo "--------------Installing Dependency ....---------------------"
	echo "------------------------------------------------------------ "
	echo ""

	echo ""
	sudo pacman -U --noconfirm "${SCRIPT_DIR}/storage/gum-0.11.0-1-x86_64.pkg.tar.zst"
	clear
}

# Handle File system

filesystem() {

	echo ""
	echo "---------------------------------------------------"
	echo "------- Choose filesytem...------------------------"
	echo "---------------------------------------------------"
	echo ""

	echo "Please Select your file system : "

	options=("btrfs" "ext4" "exit")
	fs=$(gum choose "${options[@]}")

	if [[ "$fs" == "exit" ]]; then
		exit 1
	else
		echo "$fs" >>"$CONFIG_FILE"
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

	echo ""
	echo ""
	echo ""
	echo "System detected your timezone to be '$time_zone'"
	echo "Is this correct? :"

	options=("yes" "no")
	choose=$(gum choose "${options[@]}")

	if [[ "$choose" == "yes" ]]; then

		echo "$time_zone" >>"$CONFIG_FILE"
	else
		echo "Please enter your desired timezone e.g. Europe/London :"
		read new_timezone
		if [[ "$new_timezone" == "" ]]; then
			echo ""
			echo "No timezone entered. Enter correct timezone format!"
			timezone
		else
			echo "$time_zone" >>"$CONFIG_FILE"
		fi
	fi

}

# Handle Keymap

keymap() {

	echo ""
	echo "---------------------------------------------------------"
	echo "------- Choose keyboard layout...------------------------"
	echo "---------------------------------------------------------"
	echo ""

	echo -e "Please select key board layout from this list :"

	# These are default key maps as presented in official arch repo archinstall
	options=(us by ca cf cz de dk es et fa fi fr gr hu il it lt lv mk nl no pl ro ru sg ua uk)
	keymap=$(gum choose "${options[@]}")

	echo "$keymap" >>"$CONFIG_FILE"

}

# Handle drive type

drivetype() {

	echo ""
	echo "----------------------------------------------------"
	echo "------- Choose drive type...------------------------"
	echo "----------------------------------------------------"
	echo ""

	echo -e "Is this an ssd? yes/no:"
	options=("yes" "no")
	choose=$(gum choose "${options[@]}")

	if [[ "$choose" == "yes" ]]; then
		echo "ssd" >>"$CONFIG_FILE"
	else
		echo "non-ssd" >>"$CONFIG_FILE"
	fi

}

# Handle diskpart

diskpart() {

	echo ""
	echo "------------------------------------------------------"
	echo "------- Choose diskpartiton...------------------------"
	echo "------------------------------------------------------"
	echo ""

	echo -e "
    ------------------------------------------------------------------------
        THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK
        Please make sure you know what you are doing because
        after formating your disk there is no way to get data back
    ------------------------------------------------------------------------
"

	options=($(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}'))
	disk=$(gum choose "${options[@]}" | awk -F"|" '{print $1}')
	echo "$disk" >>"$CONFIG_FILE"
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
	uname=$(gum input --placeholder "Username")
	echo "$uname" >>"$CONFIG_FILE"

	echo ""
	echo "What would be the fullname of the user?"
	fname=$(gum input --placeholder "Full Name")
	echo "$fname" >>"$CONFIG_FILE"

	echo ""
	echo "What would be the password for $uname's account?"
	passu1=$(gum input --password --placeholder "Password for $uname's account")
	echo "Type password for $uname's account again"
	passu2=$(gum input --password --placeholder "Type password for $uname's account again")
	if [[ "$passu1" == "$passu2" ]]; then
		upass=$passu2
		echo "$upass" >>"$CONFIG_FILE"
	else
		echo "Password do not match.Try running the script again!"
		rm -rf "$CONFIG_FILE"
		exit 1
	fi

	echo ""
	echo "What would be the password for root account?"
	passr1=$(gum input --password --placeholder "Password for root account")
	echo "Type password for root account again"
	passr2=$(gum input --password --placeholder "Type password for root account again")
	if [[ "$passr1" == "$passr2" ]]; then
		rpass=$passr2
		echo "$rpass" >>"$CONFIG_FILE"
	else
		echo "Password do not match.Try running the script again!"
		rm -rf "$CONFIG_FILE"
		exit 1
	fi

	echo ""
	echo "What would be the hostname?"
	nameofmachine=$(gum input --placeholder "Hostname")
	echo "$nameofmachine" >>"$CONFIG_FILE"

}

diskEncryption() {

	echo ""
	echo "---------------------------------------------------"
	echo "------- Encrypt Full DISK...-----------------------"
	echo "---------------------------------------------------"
	echo ""

	echo ""
	echo ""
	echo ""
	echo -e "Want Full Disk Encryption ? \n"

	options=("yes" "no")
	choose=$(gum choose "${options[@]}")

	if [[ "$choose" == "yes" ]]; then
		# Append Encryption status
		echo "encrypt" >>"$CONFIG_FILE"

		# Input LUKS Password
		echo -e "Input LUKS Password : \n"
		echo -e "What would be the password for LUKS Disk Encryption? \n"
		passl1=$(gum input --password --placeholder "Password :")
		echo "Type password for root account again"
		passl2=$(gum input --password --placeholder "Retype password:")
		if [[ "$passl1" == "$passl2" ]]; then
			LUKSPASS=$passl2
			echo "$LUKSPASS" >>"$CONFIG_FILE"
		else
			echo "Password do not match.Try running the script again!"
			rm -rf "$CONFIG_FILE"
			exit 1
		fi

	else
		# Append Encryption status
		echo "noencrypt" >>"$CONFIG_FILE"
	fi
}

distroType() {

	if [[ "$initType" != "systemD" ]]; then
		echo "artix" >>"$CONFIG_FILE"
	else
		echo "arch" >>"$CONFIG_FILE"
	fi
}

configure() {

	# Greet

	clear
	logo
	echo "Welcome to the pre-install script !"
	echo "Type p to proceed or e to exit"
	read keyPressed

	if [[ "${keyPressed}" = "p" ]]; then

		installDependency
		clear
		filesystem
		clear
		timezone
		clear
		keymap
		clear
		drivetype
		clear
		diskpart
		clear
		userinfo
		clear
		diskEncryption
		clear
		distroType
		clear

		# Confirmation

		_filesystemType=$(cat "$CONFIG_FILE" | sed -n '1p')
		_timezone=$(cat "$CONFIG_FILE" | sed -n '2p')
		_keyboardLayout=$(cat "$CONFIG_FILE" | sed -n '3p')
		_hardDiskType=$(cat "$CONFIG_FILE" | sed -n '4p')
		_OS_Install_Disk=$(cat "$CONFIG_FILE" | sed -n '5p')
		_username=$(cat "$CONFIG_FILE" | sed -n '6p')
		_fullname=$(cat "$CONFIG_FILE" | sed -n '7p')
		_userPassword=$(cat "$CONFIG_FILE" | sed -n '8p')
		_rootPassword=$(cat "$CONFIG_FILE" | sed -n '9p')
		_hostname=$(cat "$CONFIG_FILE" | sed -n '10p')
		_diskencrypt=$(cat "$CONFIG_FILE" | sed -n '11p')
		if [[ "$_diskencrypt" = "encrypt" ]]; then
			_lukspass=$(cat "$CONFIG_FILE" | sed -n '12p')
			_diskencrypt=$(echo -e "LUKS [aes-xts-plain64 256b] \nLUKSPASS : ${_lukspass}")
		else
			_diskencrypt="none"
		fi

		_distroType=$(sed '$!d' "$CONFIG_FILE")
		if [[ "$_distroType" == "arch" ]]; then
			_distroType=$(echo "$_distroType [systemd as init]")
		else
			_distroType=$(echo "$_distroType [openrc  as init]")
		fi

		out=$(
			echo -e "====== Final Configuration ====== \n"
			echo "filesystem : ${_filesystemType}"
			echo "timezone : ${_timezone}"
			echo "keyboard layout : ${_keyboardLayout}"
			echo "disk type : ${_hardDiskType}"
			echo "OS install disk : ${_OS_Install_Disk}"
			echo "username : ${_username}"
			echo "fullname : ${_fullname}"
			echo "userPassword : ${_userPassword}"
			echo "rootPassword : ${_rootPassword}"
			echo "hostname : ${_hostname}"
			echo "Disk Encryption : ${_diskencrypt}"
			echo "Distro variant : ${_distroType}"
		)

		gum style \
			--foreground 255 --border-foreground 39 --border double \
			--align center --width 53 --margin "1 2" --padding "2 4" \
			"$out"

		echo "Are you sure want to go with above configuration ?"
		confirm=$(gum choose "yes" "restart" "exit")

		if [[ "$confirm" = "restart" ]]; then
			rm -rf "$CONFIG_FILE"
			configure
		elif [[ "$confirm" = "yes" ]]; then
			return
		else
			rm -rf "$CONFIG_FILE"
			echo "Exited !"
			exit 1
		fi

	else
		echo "Exited !"
		rm -rf "$CONFIG_FILE"
		exit 1
	fi

}

# Take user input

configure
clear
logo
