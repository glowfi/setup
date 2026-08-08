#!/bin/bash

set -euo pipefail

# Setup
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/helpers/logo.sh"
source "${SCRIPT_DIR}/helpers/detect_init.sh"
source "${SCRIPT_DIR}/helpers/header.sh"
INIT_TYPE=$(detect_init)
CONFIG_FILE=$SCRIPT_DIR/setup.conf
: >"$CONFIG_FILE" # start with a clean, empty config file every run

set_config() {
	printf '%s=%q\n' "$1" "$2" >>"$CONFIG_FILE"
}

ask_yes_no() {
	gum choose "yes" "no"
}

ask_password() {
	local label="$1" p1 p2
	p1=$(gum input --password --placeholder "Password for $label")
	p2=$(gum input --password --placeholder "Confirm password for $label")
	if [[ "$p1" != "$p2" ]]; then
		echo "Passwords do not match. Please run the script again!"
		rm -f "$CONFIG_FILE"
		exit 1
	fi
	echo "$p1"
}

installDependency() {
	header "Installing dependencies..."
	sudo pacman -U --noconfirm "${SCRIPT_DIR}/storage/gum-0.11.0-1-x86_64.pkg.tar.zst"
	clear
}

list_timezones() {
	if command -v timedatectl >/dev/null 2>&1; then
		timedatectl list-timezones
	else
		find /usr/share/zoneinfo -type f ! -path '*/right/*' ! -path '*/posix/*' \
			! -name 'posixrules' ! -name '*.tab' ! -name 'leapseconds' ! -name 'tzdata.zi' |
			sed 's|/usr/share/zoneinfo/||' | sort
	fi
}

timezone() {
	header "Choose your timezone"
	echo "Type to search, then select your timezone:"
	tz=$(list_timezones | gum filter --placeholder "e.g. Europe/London")
	if [[ -z "$tz" ]]; then
		echo "No timezone selected."
		timezone
		return
	fi
	set_config TIMEZONE "$tz"
}

keymap() {
	header "Choose your keyboard layout"
	local layouts=(us by ca cf cz de dk es et fa fi fr gr hu il it lt lv mk nl no pl ro ru sg ua uk)
	set_config KEYMAP "$(gum choose "${layouts[@]}")"
}

filesystem() {
	header "Choose your filesystem"
	local fs
	fs=$(gum choose "btrfs" "ext4" "exit")
	[[ "$fs" == "exit" ]] && exit 1
	set_config FILESYSTEM "$fs"
}

diskpart() {
	header "Choose disk to partition"
	echo "------------------------------------------------------------------------"
	echo " THIS WILL FORMAT AND DELETE ALL DATA ON THE DISK"
	echo " Make sure you know what you're doing - there is no way to get the"
	echo " data back after formatting."
	echo "------------------------------------------------------------------------"
	echo ""

	local options disk
	options=($(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}'))
	disk=$(gum choose "${options[@]}" | cut -d'|' -f1)
	set_config DISK "$disk"
}

drivetype() {
	header "Is this an SSD?"
	if [[ "$(ask_yes_no)" == "yes" ]]; then
		set_config DISK_TYPE "ssd"
	else
		set_config DISK_TYPE "non-ssd"
	fi
}

diskEncryption() {
	header "Full disk encryption?"
	if [[ "$(ask_yes_no)" == "yes" ]]; then
		set_config DISK_ENCRYPT "encrypt"
		set_config LUKS_PASSWORD "$(ask_password "LUKS disk encryption")"
	else
		set_config DISK_ENCRYPT "noencrypt"
	fi
}

userinfo() {
	header "Enter user details"

	local uname fname upass rpass hostname_

	echo "What would be the username?"
	uname=$(gum input --placeholder "Username")
	set_config USERNAME "$uname"

	echo "What would be the full name of the user?"
	fname=$(gum input --placeholder "Full Name")
	set_config FULLNAME "$fname"

	upass=$(ask_password "$uname's account")
	set_config USER_PASSWORD "$upass"

	rpass=$(ask_password "root account")
	set_config ROOT_PASSWORD "$rpass"

	echo "What would be the hostname?"
	hostname_=$(gum input --placeholder "Hostname")
	set_config HOSTNAME "$hostname_"
}

distroType() {
	if [[ "$INIT_TYPE" != "systemD" ]]; then
		set_config DISTRO_TYPE "artix"
	else
		set_config DISTRO_TYPE "arch"
	fi
}

kernel() {
	header "Choose your kernel"
	local k
	k=$(gum choose "linux" "linux-lts" "linux-zen")
	set_config KERNEL "$k"
}

showConfirmation() {
	source "$CONFIG_FILE"

	local encryption distro
	if [[ "$DISK_ENCRYPT" == "encrypt" ]]; then
		encryption="LUKS [aes-xts-plain64 256b]"$'\n'"LUKSPASS: ${LUKS_PASSWORD}"
	else
		encryption="none"
	fi

	if [[ "$DISTRO_TYPE" == "arch" ]]; then
		distro="arch [systemd as init]"
	else
		distro="artix [openrc as init]"
	fi

	local result
	result=$(
		echo -e "====== Final Configuration ======\n"
		echo "timezone         : ${TIMEZONE}"
		echo "keyboard layout  : ${KEYMAP}"
		echo "filesystem       : ${FILESYSTEM}"
		echo "OS install disk  : ${DISK}"
		echo "disk type        : ${DISK_TYPE}"
		echo "disk encryption  : ${encryption}"
		echo "username         : ${USERNAME}"
		echo "fullname         : ${FULLNAME}"
		echo "user password    : ${USER_PASSWORD}"
		echo "root password    : ${ROOT_PASSWORD}"
		echo "hostname         : ${HOSTNAME}"
		echo "distro variant   : ${distro}"
		echo "kernel           : ${KERNEL}"
	)

	gum style \
		--foreground 255 --border-foreground 39 --border double \
		--align center --width 53 --margin "1 2" --padding "2 4" \
		"$result"
}

runSteps() {
	for step in installDependency timezone keymap filesystem diskpart drivetype diskEncryption \
		userinfo distroType kernel; do
		"$step"
		clear
	done
}

configure() {
	clear
	logo
	echo "Welcome to the pre-install script!"
	echo "Type p to proceed or e to exit"
	read -r keyPressed

	if [[ "$keyPressed" != "p" ]]; then
		echo "Exited!"
		rm -f "$CONFIG_FILE"
		exit 1
	fi

	runSteps
	showConfirmation

	echo "Are you sure you want to go with the above configuration?"
	case "$(gum choose "yes" "restart" "exit")" in
	restart)
		: >"$CONFIG_FILE"
		configure
		;;
	yes)
		return
		;;
	*)
		rm -f "$CONFIG_FILE"
		echo "Exited!"
		exit 1
		;;
	esac
}

configure
clear
logo
