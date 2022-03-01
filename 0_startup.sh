#!/usr/bin/env bash

# Script Directory
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Config file checking
CONFIG_FILE=$SCRIPT_DIR/setup.conf
if [ ! -f $CONFIG_FILE ]; then # check if file exists
	touch -f $CONFIG_FILE         # create file if not exists
fi

# Interactive
select_option() {

	# little helpers for terminal print control and key input
	ESC=$(printf "\033")
	cursor_blink_on() { printf "$ESC[?25h"; }
	cursor_blink_off() { printf "$ESC[?25l"; }
	cursor_to() { printf "$ESC[$1;${2:-1}H"; }
	print_option() { printf "$2   $1 "; }
	print_selected() { printf "$2  $ESC[7m $1 $ESC[27m"; }
	get_cursor_row() {
		IFS=';' read -sdR -p $'\E[6n' ROW COL
		echo ${ROW#*[}
	}
	get_cursor_col() {
		IFS=';' read -sdR -p $'\E[6n' ROW COL
		echo ${COL#*[}
	}
	key_input() {
		local key
		IFS= read -rsn1 key 2>/dev/null >&2
		if [[ $key = "" ]]; then echo enter; fi
		if [[ $key = $'\x20' ]]; then echo space; fi
		if [[ $key = "k" ]]; then echo up; fi
		if [[ $key = "j" ]]; then echo down; fi
		if [[ $key = "h" ]]; then echo left; fi
		if [[ $key = "l" ]]; then echo right; fi
		if [[ $key = "a" ]]; then echo all; fi
		if [[ $key = "n" ]]; then echo none; fi
		if [[ $key = $'\x1b' ]]; then
			read -rsn2 key
			if [[ $key = [A || $key = k ]]; then echo up; fi
			if [[ $key = [B || $key = j ]]; then echo down; fi
			if [[ $key = [C || $key = l ]]; then echo right; fi
			if [[ $key = [D || $key = h ]]; then echo left; fi
		fi
	}
	print_options_multicol() {
		# print options by overwriting the last lines
		local curr_col=$1
		local curr_row=$2
		local curr_idx=0

		local idx=0
		local row=0
		local col=0

		curr_idx=$(($curr_col + $curr_row * $colmax))

		for option in "${options[@]}"; do

			row=$(($idx / $colmax))
			col=$(($idx - $row * $colmax))

			cursor_to $(($startrow + $row + 1)) $(($offset * $col + 1))
			if [ $idx -eq $curr_idx ]; then
				print_selected "$option"
			else
				print_option "$option"
			fi
			((idx++))
		done
	}

	# initially print empty new lines (scroll down if at bottom of screen)
	for opt; do printf "\n"; done

	# determine current screen position for overwriting the options
	local return_value=$1
	local lastrow=$(get_cursor_row)
	local lastcol=$(get_cursor_col)
	local startrow=$(($lastrow - $#))
	local startcol=1
	local lines=$(tput lines)
	local cols=$(tput cols)
	local colmax=$2
	local offset=$(($cols / $colmax))

	local size=$4
	shift 4

	# ensure cursor and input echoing back on upon a ctrl+c during read -s
	trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
	cursor_blink_off

	local active_row=0
	local active_col=0
	while true; do
		print_options_multicol $active_col $active_row
		# user key control
		case $(key_input) in
		enter) break ;;
		up)
			((active_row--))
			if [ $active_row -lt 0 ]; then active_row=0; fi
			;;
		down)
			((active_row++))
			if [ $active_row -ge $((${#options[@]} / $colmax)) ]; then active_row=$((${#options[@]} / $colmax)); fi
			;;
		left)
			((active_col = $active_col - 1))
			if [ $active_col -lt 0 ]; then active_col=0; fi
			;;
		right)
			((active_col = $active_col + 1))
			if [ $active_col -ge $colmax ]; then active_col=$(($colmax - 1)); fi
			;;
		esac
	done

	# cursor position back to normal
	cursor_to $lastrow
	printf "\n"
	cursor_blink_on

	return $(($active_col + $active_row * $colmax))
}

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

	echo "Please Select your file system : "

	options=("btrfs" "ext4" "exit")
	select_option $? 1 "${options[@]}"

	case $? in
	0)
		echo "btrfs" >>"$CONFIG_FILE"
		;;
	1)
		echo "ext4" >>"$CONFIG_FILE"
		;;
	2)
		exit
		;;
	*)
		echo "Wrong option please select again!"
		filesystem
		;;
	esac
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
	select_option $? 1 "${options[@]}"

	case $? in
	0)
		echo "$time_zone" >>"$CONFIG_FILE"
		;;
	1)
		echo "Please enter your desired timezone e.g. Europe/London :"
		read new_timezone
		echo "$time_zone" >>"$CONFIG_FILE"
		;;
	*)
		echo "Wrong option please select again!"
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

	echo -ne "Please select key board layout from this list :"

	# These are default key maps as presented in official arch repo archinstall
	options=(us by ca cf cz de dk es et fa fi fr gr hu il it lt lv mk nl no pl ro ru sg ua uk)
	select_option $? 1 "${options[@]}"

	keymap=${options[$?]}

	if [[ "$keymap" == "" ]]; then
		echo "Wrong option please select again!"
		keymap
	else
		echo "$keymap" >>"$CONFIG_FILE"
	fi

}

# Handle drive type

drivetype() {

	echo ""
	echo "----------------------------------------------------"
	echo "------- Choose drive type...------------------------"
	echo "----------------------------------------------------"
	echo ""

	echo -ne "Is this an ssd? yes/no:"
	options=("yes" "no")
	select_option $? 1 "${options[@]}"

	case $? in
	0)
		echo "ssd" >>"$CONFIG_FILE"
		;;
	1)
		echo "non-ssd" >>"$CONFIG_FILE"
		;;
	*)
		echo "Wrong option please select again!"
		drivetype
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

	echo -ne "
    ------------------------------------------------------------------------
        THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK
        Please make sure you know what you are doing because
        after formating your disk there is no way to get data back
    ------------------------------------------------------------------------
"

	PS3='
    Select the disk to install on: '
	options=($(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}'))

	select_option $? 1 "${options[@]}"
	disk=${options[$?]%|*}

	echo -e "\n${disk%|*} Selected : \n"

	if [[ "$disk" == "" ]]; then
		echo "Wrong option please select again!"
		diskpart
	else
		echo "$disk" >>"$CONFIG_FILE"
	fi
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
		exit
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
		exit
	fi

	echo ""
	read -rep "Please enter your hostname: " nameofmachine
	echo "$nameofmachine" >>"$CONFIG_FILE"
}

# Run above functions

clear
logo

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

logo
