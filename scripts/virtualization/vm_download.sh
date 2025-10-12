#!/usr/bin/env bash

# Set your constant download location
DOWNLOAD_DIR="$HOME/Downloads/VMS_ISO"

# Create it if it doesn't exist
mkdir -p "$DOWNLOAD_DIR"

# Base family mapping
declare -A distro_family=(
	# Arch-based
	[archlinux]="arch"
	[archlinuxgui]="arch"
	[manjaro]="arch"
	[archbang]="arch"
	[parabola]="arch"
	[endeavour]="arch"
	[artix]="arch"
	[garuda]="arch"
	[archcraft]="arch"
	[cachyos]="arch"

	# Debian-based
	[debian]="deb"
	[ubuntu]="deb"
	[linuxmint]="deb"
	[zorinos]="deb"
	[popos]="deb"
	[deepin]="deb"
	[mxlinux]="deb"
	[kali]="deb"
	[puppy]="deb"
	[elementary]="deb"
	[devuan]="deb"
	[cutefishos]="deb"
	[parrot]="deb"
	[antix]="deb"
	[trisquel]="deb"
	[peppermintos]="deb"
	[damn_small_linux]="deb"
	[vanillaos]="deb"
	[tails_os]="deb"

	# RPM-based
	[fedora]="rpm"
	[opensuse]="rpm"
	[mandriva]="rpm"
	[rocky]="rpm"
	[qubes]="rpm"
	[nobara]="rpm"
	[ultramarine]="rpm"

	# Other
	[alpine]="other"
	[tinycore]="other"
	[void]="other"
	[kaos]="other"
	[clearlinux]="other"
	[slackware]="other"
	[solus]="other"

	# Source-based
	[gentoo]="sourcebased"
	[calculate]="sourcebased"
	[nixos]="sourcebased"
	[guix]="sourcebased"

	# BSD-based
	[freebsd]="bsd"
	[netbsd]="bsd"
	[openbsd]="bsd"
	[ghostbsd]="bsd"
	[dragonflybsd]="bsd"
	[midnightbsd]="bsd"
	[nomadbsd]="bsd"

	# Not Linux
	[openindiana]="notlinux"
	[minix]="notlinux"
	[haiku]="notlinux"
	[reactos]="notlinux"
	[freedos]="notlinux"

	# Windows
	[windows10]="windows"
	[windows11]="windows"

	# Bootable USB Tools
	[ventoy]="bootable_usb"
	[balena_etcher]="bootable_usb"

	# Recovery Environments
	[hirens_bootcd_pe]="recovery_environment"

	# Firewalls
	[pfsense]="firewall"
	[opnsense]="firewall"
)

# Download function mapping
declare -A distro_download=(
	# Arch-based
	[archlinux]="download_archlinux"
	[archlinuxgui]="download_archlinuxgui"
	[manjaro]="download_manjaro"
	[archbang]="download_archbang"
	[parabola]="download_parabola"
	[endeavour]="download_endeavour"
	[artix]="download_artix"
	[garuda]="download_garuda"
	[archcraft]="download_archcraft"
	[cachyos]="download_cachyos"

	# Debian-based
	[debian]="download_debian"
	[ubuntu]="download_ubuntu"
	[linuxmint]="download_linuxmint"
	[zorinos]="download_zorinos"
	[popos]="download_popos"
	[deepin]="download_deepin"
	[mxlinux]="download_mxlinux"
	[kali]="download_kali"
	[puppy]="download_puppy"
	[elementary]="download_elementary"
	[devuan]="download_devuan"
	[cutefishos]="download_cutefishos"
	[parrot]="download_parrot"
	[antix]="download_antix"
	[trisquel]="download_trisquel"
	[peppermintos]="download_peppermintos"
	[damn_small_linux]="download_damn_small_linux"
	[vanillaos]="download_vanillaos"
	[tails_os]="download_tails_os"

	# RPM-based
	[fedora]="download_fedora"
	[opensuse]="download_opensuse"
	[mandriva]="download_mandriva"
	[rocky]="download_rocky"
	[qubes]="download_qubes"
	[nobara]="download_nobara"
	[ultramarine]="download_ultramarine"

	# Other
	[alpine]="download_alpine"
	[tinycore]="download_tinycore"
	[void]="download_void"
	[kaos]="download_kaos"
	[clearlinux]="download_clearlinux"
	[slackware]="download_slackware"
	[solus]="download_solus"

	# Source-based
	[gentoo]="download_gentoo"
	[calculate]="download_calculate"
	[nixos]="download_nixos"
	[guix]="download_guix"

	# BSD-based
	[freebsd]="download_freebsd"
	[netbsd]="download_netbsd"
	[openbsd]="download_openbsd"
	[ghostbsd]="download_ghostbsd"
	[dragonflybsd]="download_dragonflybsd"
	[midnightbsd]="download_midnightbsd"
	[nomadbsd]="download_nomadbsd"

	# Not Linux
	[openindiana]="download_openindiana"
	[minix]="download_minix"
	[haiku]="download_haiku"
	[reactos]="download_reactos"
	[freedos]="download_freedos"

	# Windows
	[windows10]="download_windows10"
	[windows11]="download_windows11"

	# Bootable USB Tools
	[ventoy]="download_ventoy"
	[balena_etcher]="download_balena_etcher"

	# Recovery Environments
	[hirens_bootcd_pe]="download_hirens_bootcd_pe"

	# Firewalls
	[pfsense]="download_pfsense"
	[opnsense]="download_opnsense"
)

# Arch-based
download_archlinux() {
	local url_page="https://archlinux.org/download"
	local html=$(curl -sSLf "$url_page" | grep iso | grep https)

	local mirror=$(
		extract_links_from_html "$html" |
			grep -v -e "txt" -e "sig" -e "archiso" |
			fzf --cycle
	)

	if [[ -z "$mirror" ]]; then
		echo "❌ No ISO selected."
		return 1
	fi

	local date=$(echo "$mirror" | awk -F "/" '{print $6}')
	local download_link=$(echo "${mirror}archlinux-${date}x86_64.iso")
	local output_file="archlinux.iso"
	download "$download_link" "$output_file"
}

download_archlinuxgui() {
	local mirror="https://sourceforge.net/projects/arch-linux-gui/files/"
	local html=$(curl -sSLf "$mirror")

	local link=$(extract_links_from_html "$html" |
		grep -i "iso" | grep "download" | fzf --cycle --prompt "Choose iso to download:" | head -1 | xargs)
	download "$link" "archlinux-gui.iso"
}

download_manjaro() {
	local url_page=$(curl -sSLf "https://manjaro.org/products/download/x86")
	local iso=$(extract_links_from_html "$url_page" | grep -Ei '.+\.iso$' | fzf --cycle --prompt "Choose iso to download:" | head -1)
	download "$iso" "manjaro.iso"
}

download_archbang() {
	download "https://sourceforge.net/projects/archbang/files/latest/download" "archbang.iso"
}

download_parabola() {
	local url_page="https://wiki.parabola.nu/Get_Parabola"
	local html=$(curl -sSLf "$url_page")
	local iso=$(echo "$html" | grep -oE 'https://[^"]+\.iso' | head -1)
	[[ -z "$iso" ]] && echo "❌ No ISO found" && return 1
	download "$iso" "parabola.iso"
}

download_endeavour() {
	download "https://sourceforge.net/projects/endeavouros-repository/files/latest/download" "endeavour.iso"
}

download_artix() {
	local mirror="https://mirror.math.princeton.edu/pub/artixlinux/"
	local de=$(echo "base plasma mate lxqt lxde cinnamon xfce gtk qt" | tr " " "\n" | fzf --prompt "Choose DE:")
	local init=$(echo "dinit openrc runit s6" | tr " " "\n" | fzf --prompt "Choose init:")

	if [[ -z "$de" || -z "$init" ]]; then
		echo "❌ DE/init not selected"
		return 1
	fi

	local html=$(curl -sSLf "$mirror")
	local file=$(echo "$html" | grep -o "${de}-${init}[^\" ]*\.iso" | head -1)
	local suffix="artix"
	local link="${mirror}${suffix}-${file}"
	download "$link" "artix_${de}_${init}.iso"
}

download_garuda() {
	download "https://sourceforge.net/projects/garuda-linux/files/latest/download" "garuda.iso"
}

download_archcraft() {
	download "https://sourceforge.net/projects/archcraft/files/latest/download" "archcraft.iso"
}

download_cachyos() {
	download "https://sourceforge.net/projects/cachyos-arch/files/latest/download" "cachyos.iso"
}

# Debian-based
download_debian() {
	local mirror="https://ftp.uni-stuttgart.de/debian-cd/current-live/amd64/iso-hybrid/"
	local html=$(curl -sSLf "$mirror")
	local download_link=$(extract_links_from_html "$html" | grep "iso" | grep -v -E "contents" | grep -v -E "log" | grep -v -E "packages" | fzf --cycle --prompt "Choose iso to download:")
	local output_file="debian.iso"
	download "$mirror$download_link" "$output_file"
}

download_ubuntu() {
	local mirror="http://cdimage.ubuntu.com/daily-live/current/"
	local x=$(curl -s "$mirror" | grep -m1 desktop-amd64.iso | awk -F\" '{ print $2 }' | awk -F\" '{ print $1 }')
	local download_link="$mirror/$x"
	local output_file="ubuntu.iso"
	download "$download_link" "$output_file"
}

download_linuxmint() {
	local mirror="https://linuxmint.com/edition.php?id=302"
	local download_link=$(curl -s "$mirror" | grep -m2 iso | grep -m1 -vwE "Torrent" | awk -F"\"" '{ print $2 }')
	local output_file="linuxmint.iso"
	download "$download_link" "$output_file"
}

download_zorinos() {
	local mirror="https://sourceforge.net/projects/zorin-os/files/latest/download"
	local download_link="$mirror"
	local output_file="zorinos.iso"
	download "$download_link" "$output_file"
}

download_popos() {
	local download_link="https://iso.pop-os.org/22.04/amd64/nvidia/52/pop-os_22.04_amd64_nvidia_52.iso"
	local output_file="popos.iso"
	download "$download_link" "$output_file"
}

download_deepin() {
	local mirror="https://sourceforge.net/projects/deepin/files/latest/download"
	local download_link="$mirror"
	local output_file="deepin.iso"
	download "$download_link" "$output_file"
}

download_mxlinux() {
	local mirror="https://sourceforge.net/projects/mx-linux/files/latest/download"
	local download_link="$mirror"
	local output_file="mxlinux.iso"
	download "$download_link" "$output_file"
}

download_kali() {
	local mirror="http://cdimage.kali.org/kali-weekly/"
	local html=$(curl -sSLf "$mirror")
	local download_link=$(extract_links_from_html "$html" | grep "iso" | grep -v -E "contents" | grep -v -E "log" | grep -v -E "packages" | fzf --cycle --prompt "Choose iso to download:")
	local output_file="kali.iso"
	download "$mirror$download_link" "$output_file"
}

download_puppy() {
	local mirror="http://distro.ibiblio.org/puppylinux/puppy-bionic/bionicpup64/"
	local x=$(curl -s "$mirror" | grep -m1 uefi.iso | awk -F">" '{ print $4 }' | awk -F"<" '{ print $1 }')
	local download_link="$mirror/$x"
	local output_file="puppy.iso"
	download "$download_link" "$output_file"
}

download_elementary() {
	local mirror="https://elementary.io"
	local one=$(curl -s "$mirror" 2>&1 | grep -m1 download-link | awk -F"//" '{ print $2 }' | awk -F\" '{ print $1 }')
	local download_link="https://$one"
	local output_file="elementaryos.iso"
	download "$download_link" "$output_file"
}

download_devuan() {
	local mirror="https://devuan-cd.sedf.de/devuan_excalibur/desktop-live/"
	local html=$(curl -sSLf "$mirror")
	local download_link=$(extract_links_from_html "$html" | grep "iso" | grep -v -E "sha256" | fzf --cycle --prompt "Choose iso to download:")
	local output_file="devuan.iso"
	download "$mirror$download_link" "$output_file"
}

download_cutefishos() {
	local mirror="https://sourceforge.net/projects/cutefish-ubuntu/files/latest/download"
	local download_link="$mirror"
	local output_file="cutefishos.iso"
	download "$download_link" "$output_file"
}

download_parrot() {
	local mirror="https://deb.parrot.sh/parrot/iso/6.4/"
	local html=$(curl -sSLf "$mirror")
	local download_link=$(extract_links_from_html "$html" | grep "iso" | grep -v -E "torrent" | grep -v -E "hashes" | fzf --cycle --prompt "Choose iso to download:")
	local output_file="parrot.iso"
	download "$mirror$download_link" "$output_file"
}

download_antix() {
	local mirror="https://antixlinux.com/download/"
	local html=$(curl -sSLf "$mirror")
	local download_link=$(extract_links_from_html "$html" | grep -E "sourceforge" | grep -E "runit" | grep -E "64" | grep -E "full")
	local output_file="antix.iso"
	download "$download_link" "$output_file"
}

download_trisquel() {
	local mirror="https://mirrors.ocf.berkeley.edu/trisquel-images/"
	local html=$(curl -sSLf "$mirror")
	local download_link=$(extract_links_from_html "$html" | grep -Eo ".+iso\$" | grep trisquel | tail -1rep -Eo ".+iso\$" | grep trisquel | fzf --cycle --prompt "Choose iso to download:")
	local output_file="trisquel.iso"
	download "$mirror$download_link" "$output_file"
}

download_peppermintos() {
	local mirror="https://peppermintos.com/guide/downloading/"
	local html=$(curl -sSLf "$mirror")
	local download_link=$(extract_links_from_html "$html" | grep -Eo ".+iso\$" | fzf --cycle --prompt "Choose iso to download:")
	local output_file="peppermintos-XFCE-Debian-base.iso"
	download "$download_link" "$output_file"
}

download_damn_small_linux() {
	local mirror="https://www.damnsmalllinux.org"
	local url_page="https://www.damnsmalllinux.org/2024-download.html"
	local html=$(curl -sSLf "$url_page")
	local download_link=$(extract_links_from_html "$html" | grep -Eo ".+iso\$" | fzf --cycle --prompt "Choose iso to download:")
	local output_file="damn_small_linux.iso"
	download "$mirror$download_link" "$output_file"
}

download_vanillaos() {
	local download_link="https://download.vanillaos.org/latest.zip"
	local output_file="vanilla_os_${ver}.iso"
	download "$download_link" "$output_file"
}

download_tails_os() {
	local mirror="https://mirrors.edge.kernel.org/tails/stable/"
	local version=$(curl -s "$mirror" | grep -o 'tails-amd64-[0-9.]*' | head -n1)
	local x="https://mirrors.edge.kernel.org/tails/stable/${version}/${version}.img"
	local download_link="$x"
	local output_file="tailsos.img"
	download "$download_link" "$output_file"
}

# RPM-based
download_fedora() {
	local url_page="https://fedoraproject.org/workstation/download"
	local html=$(curl -sSLf "$url_page")
	local download_link=$(extract_links_from_html "${html}" | grep iso | fzf --cycle --prompt "Choose iso to download:")
	local output_file="fedora.iso"
	download "$download_link" "$output_file"
}

download_opensuse() {
	local mirror="https://get.opensuse.org/tumbleweed/#download"
	local download_link=$(curl -s "$mirror" | grep -m1 Current.iso | awk -F"\"" '{ print $2 }' | awk -F"\"" '{ print $1 }')
	local output_file="opensuse.iso"
	download "$download_link" "$output_file"
}

download_mandriva() {
	local mirror="https://sourceforge.net/projects/openmandriva/files/latest/download"
	local download_link="$mirror"
	local output_file="mandriva.iso"
	download "$download_link" "$output_file"
}

download_rocky() {
	local url_page="https://rockylinux.org/download"
	local html=$(curl -sSLf "$url_page")
	local download_link=$(extract_links_from_html "${html}" | grep iso | grep -v -e "CHECKSUM" | fzf --cycle --prompt "Choose iso to download:")
	local output_file="rocky.iso"
	download "$download_link" "$output_file"
}

download_qubes() {
	local mirror="https://www.qubes-os.org/downloads/"
	local download_link=$(curl -s "$mirror" | grep -m1 x86_64.iso | awk -F"\"" '{ print $4 }')
	local output_file="qubes.iso"
	download "$download_link" "$output_file"
}

download_nobara() {
	local url_page="https://nobaraproject.org/download-nobara/"
	local html=$(curl -sSLf "$url_page")
	local download_link=$(extract_links_from_html "${html}" | grep -E "iso" | fzf --cycle --prompt "Choose iso to download:")
	local output_file="nobara.iso"
	download "$download_link" "$output_file"
}

download_ultramarine() {
	local url_page="https://ultramarine-linux.org/download/"
	local html=$(curl -sSLf "$url_page")
	local download_link=$(extract_links_from_html "${html}" | grep "iso" | grep -v -e "sha256" | fzf --cycle --prompt "Choose iso to download:")
	local output_file="ultramarine.iso"
	download "$download_link" "$output_file"
}

# Other
download_alpine() {
	local url_page="https://alpinelinux.org/downloads/"
	local one=$(curl -s "$url_page" | grep Current | awk -F">" '{ print $3 }' | awk -F"<" '{ print $1 }')
	local shortv=$(echo "$one" | awk -F"." '{ print $1"."$2 }')
	local download_link="http://dl-cdn.alpinelinux.org/alpine/v$shortv/releases/x86_64/alpine-extended-$one-x86_64.iso"
	local output_file="alpine.iso"
	download "$download_link" "$output_file"
}

download_tinycore() {
	local url_page="http://tinycorelinux.net/downloads.html"
	local one=$(curl -s "$url_page" | grep TinyCore-current.iso | awk -F\" '{ print $2 }')
	local mirror="http://tinycorelinux.net/"
	local download_link="$mirror/$one"
	local output_file="tinycore.iso"
	download "$download_link" "$output_file"
}

download_void() {
	local url_page="https://voidlinux.org/download/"
	local html=$(curl -sSLf "$url_page")
	local download_link=$(extract_links_from_html "$html" | grep "iso" | fzf --cycle --prompt "Choose iso to download : ")
	local output_file="void.iso"
	download "$download_link" "$output_file"
}

download_kaos() {
	local mirror="https://sourceforge.net/projects/kaosx/files/latest/download"
	local download_link="$mirror"
	local output_file="kaos.iso"
	download "$download_link" "$output_file"
}

download_clearlinux() {
	local mirror="https://www.clearlinux.org/downloads.html"
	local ver=$(curl "$mirror" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep live | grep iso | cut -d"/" -f5 | sort | uniq | xargs)
	local download_link="https://cdn.download.clearlinux.org/releases/$ver/clear/clear-$ver-live-desktop.iso"
	local output_file="clearlinux.iso"
	download "$download_link" "$output_file"
}

download_slackware() {
	local mirror="https://mirrors.slackware.com/slackware/slackware-iso/"
	local x=$(curl -s "$mirror" | grep slackware64 | tail -1 | awk -F"slack" '{ print $2 }' | awk -F"/" '{ print $1 }')
	local other="slack$x"
	local y=$(curl -s "$mirror/$other/" | grep dvd.iso | head -1 | awk -F"slack" '{ print $2 }' | awk -F\" '{ print $1 }')
	local download_link="$mirror/$other/slack$y"
	local output_file="slackware.iso"
	download "$download_link" "$output_file"
}

download_solus() {
	local url_page="https://getsol.us/download/"
	local x=$(curl -s "$url_page" | grep -E "download" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -E "Budgie" | head -1 | grep -Eo "https.+iso")
	local download_link="$x"
	local output_file="solus.iso"
	download "$download_link" "$output_file"
}

# Source-based
download_gentoo() {
	local mirror="https://gentoo.c3sl.ufpr.br//releases/amd64/autobuilds"
	local download_link=$(
		curl -s "$mirror/latest-iso.txt" |
			grep "admin" |
			awk '{ print $1 }'
	)
	local output_file="gentoo.iso"
	download "$mirror/$download_link" "$output_file"
}

download_calculate() {
	local url_page="https://wiki.calculate-linux.org/desktop"
	local html=$(curl -sSLf "${url_page}")
	local download_link=$(extract_links_from_html "${html}" | grep "iso" | fzf --cycle --prompt "Choose iso to download :")
	local output_file="calculate.iso"
	download "$download_link" "$output_file"
}

download_nixos() {
	local url_page="https://nixos.org/download/"
	local html=$(curl -sSLf "${url_page}")
	local url=$(extract_links_from_html "${html}" | grep "sha256" | fzf --cycle --prompt "Choose iso to download :")
	local download_link=${url%.sha256}
	local output_file="nixos.iso"
	download "$download_link" "$output_file"
}

download_guix() {
	local mirror="https://guix.gnu.org/en/download/"
	local download_link=$(
		curl -s "$mirror" |
			grep ".iso" |
			awk -F"https://" '{ print $2 }' |
			awk -F\" '{ print $1 }'
	)
	local output_file="guix.iso.xz"
	download "https://$download_link" "$output_file"
}

# BSD-based
download_freebsd() {
	local mirror="https://www.freebsd.org/where/"
	local url=$(
		curl -s "$mirror" |
			grep -m1 "amd64/amd64" |
			awk -F\" '{ print $2 }'
	)
	local download_link="${url}FreeBSD$(curl -s "$url" | grep -m1 dvd1 | awk -F"FreeBSD" '{ print $2 }' | awk -F\" '{ print $1 }')"
	local output_file="freebsd.iso"
	download "$download_link" "$output_file"
}

download_netbsd() {
	local mirror="https://www.netbsd.org/"
	local download_link=$(curl -s "$mirror" | grep -m1 "CD" | awk -F\" '{ print $4 }')
	local output_file="netbsd.iso"
	download "$download_link" "$output_file"
}

download_openbsd() {
	local url_page="https://www.openbsd.org/faq/faq4.html#Download"
	local html=$(curl -sSLf "$url_page")
	local download_link=$(
		extract_links_from_html "$html" |
			grep "amd64" |
			grep "iso" |
			head -1
	)
	local output_file="openbsd.iso"
	download "$download_link" "$output_file"
}

download_ghostbsd() {
	local mirror="http://download.fr.ghostbsd.org/development/amd64/latest/"
	local download_link=$(
		curl -s -L "$mirror" |
			grep ".iso<" |
			awk -F\" '{ print $2 }' |
			fzf --cycle --prompt "Choose iso to download: "
	)
	local output_file="ghostbsd.iso"
	download "${mirror}${download_link}" "$output_file"
}

download_dragonflybsd() {
	local mirror="https://www.dragonflybsd.org/download/"
	local download_link=$(curl -s "$mirror" | grep "Uncompressed ISO:" | awk -F"\"" '{ print $2 }')
	local output_file="dragonflybsd.iso"
	download "$download_link" "$output_file"
}

download_midnightbsd() {
	local url_page="https://www.midnightbsd.org/download"
	local html=$(curl -sSLf "$url_page")
	local download_link=$(
		extract_links_from_html "$html" |
			grep "amd64" |
			grep "memstick" |
			head -1
	)
	local output_file="midnightbsd.iso"
	download "$download_link" "$output_file"
}

download_nomadbsd() {
	local mirror="https://nomadbsd.org/download.html"
	local download_link=$(curl -s "$mirror" | grep -A2 "Main site" | grep -m1 img.lzma | awk -F"\"" '{ print $2 }')
	local output_file="nomadbsd.img.lzma"
	download "$download_link" "$output_file"
}

# Not Linux
download_openindiana() {
	local url_page="https://www.openindiana.org/downloads/"
	local html=$(curl -sSLf "$url_page" | grep "Live DVD")
	local download_link=$(
		extract_links_from_html "$html" | fzf --cycle --prompt "Choose iso to download: "
	)
	local output_file="openindiana.iso"
	download "https:$download_link" "$output_file"
}

download_minix() {
	local mirror="https://wiki.minix3.org/doku.php?id=www:download:start"
	local download_link=$(
		curl -s "$mirror" |
			grep -m1 iso.bz2 |
			awk -F"http://" '{ print $2 }' |
			awk -F\" '{ print $1 }'
	)
	local output_file="minix.iso.bz2"
	download "http://$download_link" "$output_file"
}

download_haiku() {
	local mirror="https://download.haiku-os.org/nightly-images/x86_64/"
	local download_link=$(
		curl -s "$mirror" |
			grep -m1 zip |
			awk -F\" '{ print $2 }'
	)
	local output_file="haiku.zip"
	download "$download_link" "$output_file"
}

download_reactos() {
	local mirror="https://sourceforge.net/projects/reactos/files/latest/download"
	local output_file="reactos.zip"
	download "$mirror" "$output_file"
}

download_freedos() {
	local url_page="https://www.freedos.org/download/"
	local html=$(curl -sSLf "$url_page")
	local download_link=$(extract_links_from_html "${html}" | grep "zip" | fzf --cycle --prompt "Choose iso to download: ")
	local output_file="freedos.zip"
	download "$download_link" "$output_file"
}

# Windows
build_unattended_windows_xml() {
	cat <<'EOF' >"${1}"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend"
  xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <!--
       For documentation on components:
       https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/
  -->
  <settings pass="offlineServicing">
    <component name="Microsoft-Windows-LUA-Settings" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <EnableLUA>false</EnableLUA>
    </component>
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <ComputerName>*</ComputerName>
    </component>
  </settings>

  <settings pass="generalize">
    <component name="Microsoft-Windows-PnPSysprep" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
      <PersistAllDeviceInstalls>true</PersistAllDeviceInstalls>
    </component>
    <component name="Microsoft-Windows-Security-SPP" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <SkipRearm>1</SkipRearm>
    </component>
  </settings>

  <settings pass="specialize">
    <component name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <SkipAutoActivation>true</SkipAutoActivation>
    </component>
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <ComputerName>*</ComputerName>
      <OEMInformation>
        <Manufacturer>KVM/QEMU Project</Manufacturer>
        <Model>KVM/QEMU</Model>
        <SupportHours>24/7</SupportHours>
        <SupportPhone></SupportPhone>
        <SupportProvider>KVM/QEMU Project</SupportProvider>
        <SupportURL>https://www.qemu.org/</SupportURL>
      </OEMInformation>
      <OEMName>KVM/QEMU Project</OEMName>
      <ProductKey>W269N-WFGWX-YVC9B-4J6C9-T83GX</ProductKey>
    </component>
    <component name="Microsoft-Windows-SQMApi" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <CEIPEnabled>0</CEIPEnabled>
    </component>
  </settings>

  <settings pass="windowsPE">
    <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <Diagnostics>
        <OptIn>false</OptIn>
      </Diagnostics>
      <DiskConfiguration>
        <Disk wcm:action="add">
          <DiskID>0</DiskID>
          <WillWipeDisk>true</WillWipeDisk>
          <CreatePartitions>
            <!-- Windows RE Tools partition -->
            <CreatePartition wcm:action="add">
              <Order>1</Order>
              <Type>Primary</Type>
              <Size>256</Size>
            </CreatePartition>
            <!-- System partition (ESP) -->
            <CreatePartition wcm:action="add">
              <Order>2</Order>
              <Type>EFI</Type>
              <Size>128</Size>
            </CreatePartition>
            <!-- Microsoft reserved partition (MSR) -->
            <CreatePartition wcm:action="add">
              <Order>3</Order>
              <Type>MSR</Type>
              <Size>128</Size>
            </CreatePartition>
            <!-- Windows partition -->
            <CreatePartition wcm:action="add">
              <Order>4</Order>
              <Type>Primary</Type>
              <Extend>true</Extend>
            </CreatePartition>
          </CreatePartitions>
          <ModifyPartitions>
            <!-- Windows RE Tools partition -->
            <ModifyPartition wcm:action="add">
              <Order>1</Order>
              <PartitionID>1</PartitionID>
              <Label>WINRE</Label>
              <Format>NTFS</Format>
              <TypeID>DE94BBA4-06D1-4D40-A16A-BFD50179D6AC</TypeID>
            </ModifyPartition>
            <!-- System partition (ESP) -->
            <ModifyPartition wcm:action="add">
              <Order>2</Order>
              <PartitionID>2</PartitionID>
              <Label>System</Label>
              <Format>FAT32</Format>
            </ModifyPartition>
            <!-- MSR partition does not need to be modified -->
            <ModifyPartition wcm:action="add">
              <Order>3</Order>
              <PartitionID>3</PartitionID>
            </ModifyPartition>
            <!-- Windows partition -->
              <ModifyPartition wcm:action="add">
              <Order>4</Order>
              <PartitionID>4</PartitionID>
              <Label>Windows</Label>
              <Letter>C</Letter>
              <Format>NTFS</Format>
            </ModifyPartition>
          </ModifyPartitions>
        </Disk>
      </DiskConfiguration>
      <DynamicUpdate>
        <Enable>true</Enable>
        <WillShowUI>Never</WillShowUI>
      </DynamicUpdate>
      <ImageInstall>
        <OSImage>
          <InstallTo>
            <DiskID>0</DiskID>
            <PartitionID>4</PartitionID>
          </InstallTo>
          <InstallToAvailablePartition>false</InstallToAvailablePartition>
        </OSImage>
      </ImageInstall>
      <RunSynchronous>
        <RunSynchronousCommand wcm:action="add">
          <Order>1</Order>
          <Path>reg add HKLM\System\Setup\LabConfig /v BypassCPUCheck /t REG_DWORD /d 0x00000001 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>2</Order>
          <Path>reg add HKLM\System\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 0x00000001 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>3</Order>
          <Path>reg add HKLM\System\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 0x00000001 /f</Path>
        </RunSynchronousCommand>
        <RunSynchronousCommand wcm:action="add">
          <Order>4</Order>
          <Path>reg add HKLM\System\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 0x00000001 /f</Path>
        </RunSynchronousCommand>
      </RunSynchronous>
      <UpgradeData>
        <Upgrade>false</Upgrade>
        <WillShowUI>Never</WillShowUI>
      </UpgradeData>
      <UserData>
        <AcceptEula>true</AcceptEula>
        <FullName><USERNAME_HERE></FullName>
        <Organization>KVM/QEMU Project</Organization>
        <!-- https://docs.microsoft.com/en-us/windows-server/get-started/kms-client-activation-keys -->
        <ProductKey>
          <Key>W269N-WFGWX-YVC9B-4J6C9-T83GX</Key>
          <WillShowUI>Never</WillShowUI>
        </ProductKey>
      </UserData>
    </component>

    <component name="Microsoft-Windows-PnpCustomizationsWinPE" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="amd64" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <!--
           This makes the VirtIO drivers available to Windows, assuming that
           the VirtIO driver disk is available as drive E:
           https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md
      -->
      <DriverPaths>
        <PathAndCredentials wcm:action="add" wcm:keyValue="1">
          <Path>E:\qemufwcfg\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="2">
          <Path>E:\vioinput\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="3">
          <Path>E:\vioscsi\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="4">
          <Path>E:\viostor\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="5">
          <Path>E:\vioserial\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="6">
          <Path>E:\qxldod\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="7">
          <Path>E:\amd64\w10</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="8">
          <Path>E:\viogpudo\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="9">
          <Path>E:\viorng\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="10">
          <Path>E:\NetKVM\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="11">
          <Path>E:\viofs\w10\amd64</Path>
        </PathAndCredentials>
        <PathAndCredentials wcm:action="add" wcm:keyValue="12">
          <Path>E:\Balloon\w10\amd64</Path>
        </PathAndCredentials>
      </DriverPaths>
    </component>
  </settings>

  <settings pass="oobeSystem">
    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <AutoLogon>
        <Password>
          <Value><USERNAME_HERE></Value>
          <PlainText>true</PlainText>
        </Password>
        <Enabled>true</Enabled>
        <Username><USERNAME_HERE></Username>
      </AutoLogon>
      <DisableAutoDaylightTimeSet>false</DisableAutoDaylightTimeSet>
      <OOBE>
        <HideEULAPage>true</HideEULAPage>
        <HideLocalAccountScreen>true</HideLocalAccountScreen>
        <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
        <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
        <NetworkLocation>Home</NetworkLocation>
        <ProtectYourPC>3</ProtectYourPC>
        <SkipUserOOBE>true</SkipUserOOBE>
        <SkipMachineOOBE>true</SkipMachineOOBE>
        <VMModeOptimizations>
          <SkipWinREInitialization>true</SkipWinREInitialization>
        </VMModeOptimizations>
      </OOBE>
      <UserAccounts>
        <LocalAccounts>
          <LocalAccount wcm:action="add">
            <Password>
              <Value><USERNAME_HERE></Value>
              <PlainText>true</PlainText>
            </Password>
            <Description><USERNAME_HERE></Description>
            <DisplayName><USERNAME_HERE></DisplayName>
            <Group>Administrators</Group>
            <Name><USERNAME_HERE></Name>
          </LocalAccount>
        </LocalAccounts>
      </UserAccounts>
      <RegisteredOrganization>KVM/QEMU Project</RegisteredOrganization>
      <RegisteredOwner><USERNAME_HERE></RegisteredOwner>
      <FirstLogonCommands>
        <SynchronousCommand wcm:action="add">
          <CommandLine>msiexec /i E:\guest-agent\qemu-ga-x86_64.msi /quiet /passive /qn</CommandLine>
          <Description>Install Virtio Guest Agent</Description>
          <Order>1</Order>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <CommandLine>msiexec /i F:\spice-webdavd-x64-latest.msi /quiet /passive /qn</CommandLine>
          <Description>Install spice-webdavd file sharing agent</Description>
          <Order>2</Order>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <CommandLine>msiexec /i F:\UsbDk_1.0.22_x64.msi /quiet /passive /qn</CommandLine>
          <Description>Install usbdk USB sharing agent</Description>
          <Order>3</Order>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <CommandLine>msiexec /i F:\spice-vdagent-x64-0.10.0.msi /quiet /passive /qn</CommandLine>
          <Description>Install spice-vdagent SPICE agent</Description>
          <Order>4</Order>
        </SynchronousCommand>
        <SynchronousCommand wcm:action="add">
          <CommandLine>Cmd /c POWERCFG -H OFF</CommandLine>
          <Description>Disable Hibernation</Description>
          <Order>5</Order>
        </SynchronousCommand>
      </FirstLogonCommands>
    </component>
  </settings>
</unattend>
EOF
}

getWindowsISOLink() {
	# Define product IDs and names
	declare -A products=(
		["2618"]="❤️ Windows 10 22H2 v1 (19045.2965)"
		["3113"]="❤️ Windows 11 24H2 (26100.1742)"
	)

	if [[ "$1" = "windows10" ]]; then
		local selected_product_id="2618"
	elif [[ "$1" = "windows11" ]]; then
		local selected_product_id="3113"
	else
		echo "Unsupported windows product $1"
		exit 1
	fi

	# Fetch SKU information for the selected product ID
	local sku_response=$(curl -s "https://api.gravesoft.dev/msdl/skuinfo?product_id=$selected_product_id")

	# Use jq to extract and format the SKU information
	local selected_sku=$(echo "$sku_response" | jq -r '.Skus[] | "\(.Id) \(.Description)"' | sort | fzf --header="Select a SKU")

	# Check if a SKU was selected
	if [ -z "$selected_sku" ]; then
		echo "No SKU selected."
		exit 1
	fi

	# Extract the SKU ID from the selected SKU
	local sku_id=$(echo "$selected_sku" | awk '{print $1}')

	# Fetch download options for the selected SKU
	local download_response=$(curl -s "https://api.gravesoft.dev/msdl/proxy?product_id=$selected_product_id&sku_id=$sku_id")

	# Use jq to extract and format the download options
	local selected_download=$(echo "$download_response" | jq -r '.ProductDownloadOptions[] | "\(.Name) \(.Uri)"' | fzf --header="Select a download option")

	# Check if a download option was selected
	if [ -z "$selected_download" ]; then
		echo "No download option selected."
		exit 1
	fi

	# Extract the download URL from the selected download option
	local downloadLink=$(echo "$selected_download" | awk '{print $NF}')

	echo "${downloadLink}"
}

download_drivers() {
	echo -e "Downloading Spice Agents for copy paste functionality ..."
	download "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-latest.msi" "spice-webdavd-x64-latest.msi"
	download "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/spice-vdagent-x64-0.10.0.msi" "spice-vdagent-x64-0.10.0.msi"
	download "https://www.spice-space.org/download/windows/usbdk/UsbDk_1.0.22_x64.msi" "UsbDk_1.0.22_x64.msi"
}

download_windows() {
	# CACHE PASSWORD
	sudo sed -i '71 a Defaults        timestamp_timeout=30000' /etc/sudoers

	# Check if unattended user is needed
	read -p "Do you want an unattended installer ? (y/n/yes/no):" use_unattended_installer
	local admin_username=""
	if [[ "${use_unattended_installer}" = "y" || "${use_unattended_installer}" = "yes" ]]; then
		read -p "Enter username for your account:" admin_username
	fi

	local windows_version="$1"
	local iso_download_url=$(getWindowsISOLink "$windows_version")
	local iso_file_name="${windows_version}.iso"

	if [[ -z "${iso_download_url}" ]]; then
		echo "No windows iso link found"
		exit 1
	fi

	# download windows iso
	local current_timestamp=$(date +%s)
	local temporary_download_directory=$(echo "${DOWNLOAD_DIR}/tmp_download-${windows_version}-${current_timestamp}")
	mkdir -p "${temporary_download_directory}"
	cd "${temporary_download_directory}"
	download "${iso_download_url}" "${iso_file_name}"

	# mount downloaded iso
	mkdir iso_mount
	sudo mount -o rw,loop "${iso_file_name}" iso_mount

	# copy all the content of iso to a folder
	local new_timestamp=$(date +%s)
	local modified_windows_directory="${temporary_download_directory}/win-${new_timestamp}"
	mkdir "${modified_windows_directory}"
	sudo cp -r iso_mount/* "${modified_windows_directory}"

	# add drivers and unattended.xml file
	local modification_directory="${temporary_download_directory}/modifications-${new_timestamp}"
	mkdir "${modification_directory}"
	cd "${modification_directory}"

	if [[ "${use_unattended_installer}" = "y" || "${use_unattended_installer}" = "yes" ]]; then
		echo "Creating unattended installer ...."
		build_unattended_windows_xml "${modification_directory}/autounattend.xml"
		sed -i "s/<USERNAME_HERE>/${admin_username}/g" "${modification_directory}/autounattend.xml"
		sed -i "s/ Project//g" "${modification_directory}/autounattend.xml"

		download_drivers
	else
		echo "Creating non-unattended installer ...."
	fi
	cd ..

	# unmount iso
	sudo umount iso_mount
	sudo rm -rf iso_mount

	# build iso
	local iso_file_name_final=""
	local iso_file_suffix=""
	if [[ "${use_unattended_installer}" = "y" || "${use_unattended_installer}" = "yes" ]]; then
		iso_file_suffix="unattended"
	else
		iso_file_suffix="non-unattended"
	fi
	local new_timestamp=$(date +%s)
	iso_file_name_final="${windows_version}-${iso_file_suffix}-${new_timestamp}.iso"

	mkisofs \
		-iso-level 4 \
		-rock \
		-disable-deep-relocation \
		-untranslated-filenames \
		-b boot/etfsboot.com \
		-no-emul-boot \
		-boot-load-size 8 \
		-eltorito-alt-boot \
		-eltorito-platform efi \
		-b efi/microsoft/boot/efisys.bin \
		-o "../${iso_file_name_final}" \
		"${modified_windows_directory}" "${modification_directory}"

	# Download virtio iso
	cd "${DOWNLOAD_DIR}"
	rm -rf "virtio.iso"
	echo "Downloading Virtio Drivers for setting higher resolution ..."
	download "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso" "virtio.iso"

	# Delete Temp Windows Directory
	sudo rm -rf "${temporary_download_directory}"

	# DELETE CACHED PASSWORD
	sudo sed -i '72d' /etc/sudoers
}

download_windows10() {
	download_windows "windows10"
}

download_windows11() {
	download_windows "windows11"
}

# Bootable USB Tools
download_ventoy() {
	local url_page="https://github.com/ventoy/Ventoy"

	local html
	html=$(curl -fsSL "$url_page")
	local ver
	ver=$(extract_links_from_html "$html" | grep -i "releases/tag" | cut -d"/" -f6 | xargs | tr -d "v")

	# Construct download link
	local download_link="${url_page}/releases/download/v$ver/ventoy-$ver-linux.tar.gz"
	local output_file="ventoy.tar.gz"

	# Download the file
	download "$download_link" "$output_file"
}

download_balena_etcher() {
	local url_page="https://github.com/balena-io/etcher"

	local html
	html=$(curl -fsSL "$url_page")
	ver=$(extract_links_from_html "$html" | grep -i "releases/tag" | cut -d"/" -f6 | xargs | tr -d "v")

	# local download_link
	download_link="${url_page}/releases/download/v$ver/balenaEtcher-${ver}-x64.AppImage"
	local output_file="balena_etcher.AppImage"

	# Download the file
	download "$download_link" "$output_file"
}

# Recovery Environments
download_hirens_bootcd_pe() {
	local download_link="https://www.hirensbootcd.org/files/HBCD_PE_x64.iso"
	local output_file="HBCD_PE_x64.iso"

	# Download the file
	download "$download_link" "$output_file"
}

# Firewalls

download_pfsense() {
	local mirror="https://atxfiles.netgate.com/mirror/downloads/"
	local iso_file

	# Fetch the latest ISO link
	iso_file=$(curl -s "$mirror" | grep -oP 'href="\K[^"]*amd64\.iso\.gz' | tail -1)

	# Check if the ISO file was found
	if [[ -z "$iso_file" ]]; then
		echo "Error: No ISO file found at the specified mirror."
		return 1
	fi

	local download_link="${mirror}${iso_file}"
	local output_file="pfsense.iso.gz"

	# Download the file
	download "$download_link" "$output_file"
}

download_opnsense() {
	local mirror="https://mirror.dns-root.de/opnsense/releases/mirror/"
	local version_dir iso_file

	# Fetch the latest version directory (e.g. 24.1/)
	version_dir=$(curl -fsSL "$mirror" | grep -B1 mirror | head -1 | awk -F'"' '{ print $2 }')

	if [[ -z "$version_dir" ]]; then
		echo "Error: Could not find version directory from mirror."
	fi

	# Fetch the ISO file
	iso_file=$(curl -fsSL "${mirror}${version_dir}" | grep -m1 dvd | awk -F'"' '{ print $2 }')

	if [[ -z "$iso_file" ]]; then
		echo "Error: Could not find ISO file in version directory '$version_dir'."
	fi

	local download_link="${mirror}${version_dir}${iso_file}"
	local output_file="opnsense.iso.bz2"

	# Download the file
	download "$download_link" "$output_file"
}

# Download function
download() {
	local url="$1"
	local output="$2"

	echo "📥 Downloading from: $url"

	if command -v aria2c >/dev/null 2>&1; then
		echo "⬇️  Trying aria2c: $output"
		aria2c -j 16 -x 16 -s 16 -k 1M "$url" -o "$output"
		if [[ $? -eq 0 ]]; then return 0; else echo "❌ aria2c failed, falling back to curl..."; fi
	fi

	if command -v curl >/dev/null 2>&1; then
		echo "⬇️  Trying curl: $output"
		curl -L --fail --speed-time 30 --speed-limit 1000 "$url" -o "$output"
		if [[ $? -eq 0 ]]; then return 0; else echo "❌ curl failed, falling back to wget..."; fi
	fi

	if command -v wget >/dev/null 2>&1; then
		echo "⬇️  Trying wget: $output"
		wget --read-timeout=30 --timeout=30 -c "$url" -O "$output"
		if [[ $? -eq 0 ]]; then return 0; else echo "❌ wget also failed."; fi
	fi

	echo "❌ All download methods failed for: $url"
	return 1
}

# Extract links html from html
extract_links_from_html() {
	local html="$1"
	echo "$html" | grep -o '<a .*href=.*' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d'
}

# Dispatcher function
download_distro() {
	local distro="$1"
	local func="${distro_download[$distro]}"

	if [[ -z "$func" ]]; then
		echo "❌ No download function registered for '$distro'"
		return 1
	fi

	if ! declare -f "$func" >/dev/null; then
		echo "❌ Download function '$func' is not defined"
		return 1
	fi

	local initial_dir
	initial_dir=$(pwd)

	echo "⬇️ Downloading $distro (family: ${distro_family[$distro]}) to $DOWNLOAD_DIR"

	cd "$DOWNLOAD_DIR" || {
		echo "❌ Failed to cd into $DOWNLOAD_DIR"
		return 1
	}

	# Run the download function (which should save files in the current directory)
	"$func"

	cd "$initial_dir" || {
		echo "❌ Failed to return to $initial_dir"
		return 1
	}

	echo "✅ Finished download of $distro"
}

# Selector
select_distro() {
	# Prepare list: "distro (family)"
	# Sort first by family name, then by distro name
	local options
	options=$(for d in "${!distro_family[@]}"; do
		echo "$d ${distro_family[$d]}"
	done | sort -k2,2 -k1,1 | awk '{print $1 " (" $2 ")"}')

	# Run fzf to select
	local selected
	selected=$(echo "$options" | fzf --cycle --prompt="Select an OS or tool to download: " --height=15 --border) || return 1

	# Extract distro name before space
	local distro_name="${selected%% *}"

	if [[ -z "$distro_name" ]]; then
		log "No distro selected, exiting."
		return 1
	fi

	download_distro "$distro_name"
}

# Main
if ! command -v fzf &>/dev/null; then
	echo "❌ fzf not found! Please install fzf to use this script."
	exit 1
fi

select_distro
