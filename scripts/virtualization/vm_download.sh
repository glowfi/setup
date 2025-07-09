#!/bin/bash

helpsection() {
	echo -e "/----------------------------------------------------------------------------------------------------------------------------------------\\"
	echo -e "|\e[34m Script downloads recent (latest release) linux ISOs and spins a VM for a test. This is kinda distrohopper dream machine.               \e[0m|"
	echo -e "|\e[34m Theoretically, the script should always download recent linux ISOs without any updates. But, if the developer(s)                       \e[0m|"
	echo -e "|\e[34m change the download URL or something else, it might be required to do manual changes.                                                  \e[0m|"
	echo -e "|\e[35m                                                                                                                                        \e[0m|"
	echo -e "|\e[33m  Supported : Arch-based-distros , DEB-based-distros , RPM-based-distros                                                                \e[0m|"
	echo -e "|\e[33m              Source-based-linux-distros , 'Containers and data-center-based-os' , 'BSD, NAS, Firewall'                                 \e[0m|"
	echo -e "|\e[33m              Not-linux[openindiana minix haiku menuetos kolibri reactos freedos] , Windows , Bootable_USB , Recovery Environment       \e[0m|"
	echo -e "|\e[33m Some distros are shared as archive. So you'll need xz for guix, bzip2 for minix, zip for haiku & reactos, and, finally 7z for kolibri. \e[0m|"
	echo -e "|\e[35m                                                                                                                                        \e[0m|"
	echo -e "|\e[31m Requirements: linux, bash, curl, wget, awk, grep, xargs, pr, aria2, fzf, mkisofs                                                       \e[0m|"
	echo -e "|\e[31m Inspired By : https://github.com/sxiii/linux-downloader , quickget (QUICKEMU Project)                                                  \e[0m|"
	echo -e "/----------------------------------------------------------------------------------------------------------------------------------------\\"
	echo -e ""
	echo -e "====== How to use ====== \n"
	echo -e "\e[32m+ To Download Just One ISO press enter by selecting the iso in the fuzzy menu and it will automatically start downloading \n\e[0m"
	echo -e "\e[32m+ To Download Multiple ISOs press tab to select multiple OS and the enter to start downloading \n\e[0m"
}

# the public ipxe mirror does not work
#echo "* 'netbootipxe' option will boot from boot.ipxe.org"

#### Constant Variables
allDistros=""
VMS_ISO="$HOME/Downloads/VMS_ISO"

#### Temp Variables
windowsGlobalDownloadLink=""

# Download functions and commands

download() {
	mkdir -p "${VMS_ISO}"
	cd "${VMS_ISO}"
	echo "Downloading $new to $output"
	aria2c -j 16 -x 16 -s 16 -k 1M "${new}" -o "${output}"
}

# Function to only get filesize
getsize() {
	abc=$(wget --spider $new 2>&1)
	y=$(echo $abc | awk -F"Length:" '{ print $2 }' | awk -F"[" '{ print $1 }')
	ss=$(ls -l -B $output | awk -F" " '{ print $5 }')
	sh=$(ls -lh $output | awk -F" " '{ print $5 }')
	printf "File: $new has size: $y while on disk it is $output - $ss ($sh) \n"
}

# This can be adopted for using torrents instead of direct HTTP/FTP files
ariacmd() { aria2c --seed-time=0 -c $new; }
# Set seeding time after downloading to zero ( this is sad :-( remove --seed-time=0 if you like to seed :-) )

# Other functions

notlive() {
	echo " / / ---------------------------------------------------------------------- \ \ "
	echo " | | Note: this is not a live disk (it'll require further installation).    | | "
	echo " \ \ -----------------------------------------------------------------------/ / "
}

notlinux() {
	echo " / / ------------------------------------------------------------------------------------- \ \ "
	echo " | | Note: this isn't actually linux. It was included as it's important opensource project | | "
	echo " \ \ --------------------------------------------------------------------------------------/ / "
}

empty() {
	echo "The file $output is empty. Please download it first." # This function does nothing
}

checkfile() {
	if [ "$1" == "filesize" ]; then
		[ -s $output ] && getsize || empty
	else
		download
	fi
}

# Update latest distro URL functions

archurl() {
	mirror="https://archlinux.org/download"
	arch_mirror=$(curl -sSLf https://archlinux.org/download | grep iso | grep https | grep -o '<a .*href=.*' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -v -e "txt" -e "sig" -e "archiso" | fzf --cycle)
	date=$(echo "$arch_mirror" | awk -F "/" '{print $6}')
	new=$(echo "${arch_mirror}archlinux-${date}-x86_64.iso")
	output="archlinux.iso"
	checkfile $1
}

archguiurl() {
	de_wm=$(echo -e "cutefish\ngnome\nplasma\nmate\nxfce\ncinnamon\nlxqt\nxp\nwayland\nbudgie\ni3\nbspwm" | fzf -m --prompt "Choose DE/WM for Arch:" --cycle | tr "\n" ",")
	IFS=',' read -ra my_array < <(echo "$de_wm")
	mirror="https://sourceforge.net/projects/arch-linux-gui/files/"

	for element in "${my_array[@]}"; do
		link=$(curl "$mirror" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "iso" | grep "download" | grep "$element" | head -1 | xargs)
		new="$link"
		output="archlinux-gui-${element}.iso"
		checkfile $1
	done
}

manjarourl() {
	mirror="https://manjaro.org/download/"
	x=$(curl -s $mirror | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep minimal | grep kde | grep -E ".+.iso$")
	new="$x"
	output="manjaro.iso"
	checkfile $1
}

arcourl() {
	mirror="https://bike.seedhost.eu/arcolinux/iso/"
	x=$(curl -s $mirror | grep -m1 arcolinux- | awk -F">" '{ print $3 }' | awk -F"<" '{ print $1 }')
	new="$mirror/$x"
	output="arcolinux.iso"
	checkfile $1
}

archbangurl() {
	mirror="https://sourceforge.net/projects/archbang/files/latest/download"
	new="$mirror"
	output="archbang.iso"
	checkfile $1
}

parabolaurl() {
	mirror="https://wiki.parabola.nu/Get_Parabola"
	new=$(curl -s $mirror | grep iso | grep Web | awk -F"\"" '{ print $18 }' | grep iso -m1)
	output="parabola.iso"
	checkfile $1
}

endeavoururl() {
	mirror="https://sourceforge.net/projects/endeavouros-repository/files/latest/download"
	new="$mirror"
	output="endeavour.iso"
	checkfile $1
}

artixurl() {
	mirror="https://mirrors.dotsrc.org/artix-linux/iso/"
	de_wm="base plasma mate lxqt lxde cinnamon xfce gtk qt"
	init="dinit openrc runit s6"

	choose_de_wm=$(echo "${de_wm}" | tr " " "\n" | fzf --prompt "Choose Desktop Environment:")
	choose_init=$(echo "${init}" | tr " " "\n" | fzf --prompt "Choose init:")

	if [[ "${choose_de_wm}" != "" && "${choose_init}" != "" ]]; then
		x=$(curl -s $mirror | grep "${choose_de_wm}-${choose_init}" | head -1 | awk -F\" '{ print $2 }')
		new="$mirror/$x"
		output="artix_${choose_de_wm}_${choose_init}.iso"
		checkfile $1
	else
		echo "Please choose a valid option!"
	fi

}

arcourl() {
	mirror="https://sourceforge.net/projects/arcolinux/files/latest/download"
	new="$mirror"
	output="arco.iso"
	checkfile $1
}

garudaurl() {
	mirror="https://sourceforge.net/projects/garuda-linux/files/latest/download"
	new="$mirror"
	output="garuda.iso"
	checkfile $1
}

rebornurl() {
	mirror="https://sourceforge.net/projects/rebornos/files/latest/download"
	new="$mirror"
	output="rebornos.iso"
	checkfile $1
}

namiburl() {
	mirror="https://sourceforge.net/projects/namib-gnu-linux/files/latest/download"
	new="$mirror"
	output="namib.iso"
	checkfile $1
}

obarunurl() {
	mirror="https://repo.obarun.org/iso/"
	x=$(curl -s $mirror | grep "<tr><td" | tail -1 | awk -F"href=\"" '{ print $2 }' | awk -F"/" '{ print $1 }')
	y=$(curl -s $mirror/$x/ | grep obarun | head -1 | awk -F"href=\"" '{ print $2 }' | awk -F\" '{ print $1 }')
	new="$mirror/$x/$y"
	output="obarun.iso"
	checkfile $1
}

archcrafturl() {
	mirror="https://sourceforge.net/projects/archcraft/files/latest/download"
	new="$mirror"
	output="archcraft.iso"
	checkfile $1
}

peuxurl() {
	mirror="https://sourceforge.net/projects/peux-os/files/latest/download"
	new="$mirror"
	output="peuxos.iso"
	checkfile $1
}

bluestarurl() {
	mirror="https://sourceforge.net/projects/bluestarlinux/files/latest/download"
	new="$mirror"
	output="bluestar.iso"
	checkfile $1
}

xerourl() {
	mirror="https://sourceforge.net/projects/xerolinux/files/latest/download"
	new="$mirror"
	output="xerolinux.iso"
	checkfile $1
}

cachyosurl() {
	mirror="https://mirror.cachyos.org/ISO/kde/"
	latest=$(curl "$mirror" | grep date | grep -oE '[0-9]{6,10}' | uniq | sort | tail -1)
	iso=$(curl "$mirror$latest/" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -Eo ".+iso\$")
	new="$mirror$latest/$iso"
	output="cachyos.iso"
	checkfile $1
}

debianurl() {
	x="https://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-dvd/debian-testing-amd64-DVD-1.iso"
	new="$x"
	output="debian.iso"
	notlive
	checkfile $1
}

ubuntuurl() {
	mirror="http://cdimage.ubuntu.com/daily-live/current/"
	x=$(curl -s $mirror | grep -m1 desktop-amd64.iso | awk -F\" '{ print $2 }' | awk -F\" '{ print $1 }')
	new="$mirror/$x"
	output="ubuntu.iso"
	checkfile $1
}

minturl() {
	mirror="https://linuxmint.com/edition.php?id=302"
	new=$(curl -s $mirror | grep -m2 iso | grep -m1 -vwE "Torrent" | awk -F"\"" '{ print $2 }')
	output="linuxmint.iso"
	checkfile $1
}

alturl() {
	x="http://mirror.yandex.ru/altlinux-nightly/current/regular-cinnamon-latest-x86_64.iso"
	new="$x"
	output="altlinux.iso"
	checkfile $1
}

zorinurl() {
	mirror="https://sourceforge.net/projects/zorin-os/files/latest/download"
	new="$mirror"
	output="zorinos.iso"
	checkfile $1
}

popurl() {
	new="https://iso.pop-os.org/22.04/amd64/nvidia/52/pop-os_22.04_amd64_nvidia_52.iso"
	output="popos.iso"
	checkfile $1
}

deepinurl() {
	mirror="https://sourceforge.net/projects/deepin/files/latest/download"
	new="$mirror"
	output="deepin.iso"
	notlive
	checkfile $1
}

mxurl() {
	mirror="https://sourceforge.net/projects/mx-linux/files/latest/download"
	new="$mirror"
	output="mxlinux.iso"
	checkfile $1
}

knoppixurl() {
	mirror="http://mirror.yandex.ru/knoppix/DVD/"
	x=$(curl -s $mirror | grep -m1 "EN.iso\"" | awk -F"\"" '{ print $2 }')
	new="$mirror/$x"
	output="knoppix.iso"
	checkfile $1
}

kaliurl() {
	mirror="http://cdimage.kali.org/kali-weekly/"
	x=$(curl -s $mirror | grep -m1 live-amd64.iso | awk -F">" '{ print $7 }' | awk -F"<" '{ print $1 }')
	new="$mirror/$x"
	output="kali.iso"
	checkfile $1
}

puppyurl() {
	mirror="http://distro.ibiblio.org/puppylinux/puppy-bionic/bionicpup64/"
	x=$(curl -s $mirror | grep -m1 uefi.iso | awk -F">" '{ print $4 }' | awk -F"<" '{ print $1 }')
	new="$mirror/$x"
	output="puppy.iso"
	checkfile $1
}

pureurl() {
	mirror="https://pureos.net/download/"
	new=$(curl -s $mirror | grep -m1 iso | awk -F"\"" '{ print $2 }')
	output="pureos.iso"
	checkfile $1
}

elementurl() {
	mirror="https://elementary.io"
	one=$(curl -s $mirror 2>&1 | grep -m1 download-link | awk -F"//" '{ print $2 }' | awk -F\" '{ print $1 }')
	new="https://$one"
	output="elementaryos.iso"
	checkfile $1
}

backboxurl() {
	mirror="https://bit.ly/2yNWmF3"
	new="$mirror"
	output="backbox.iso"
	checkfile $1
}

devuanurl() {
	mirror="https://www.devuan.org/get-devuan"
	x=$(curl -s $mirror | grep -A5 HTTPS | grep href | awk -F"\"" '{ print $2 }')
	one=$(curl -s $x | grep daed | awk -F"\"" '{ print $4 }')
	two=$(curl -s $x/$one | grep desktop-live | awk -F"\"" '{ print $4 }')
	three=$(curl -s $x/$one/$two | grep -m1 amd64 | awk -F"\"" '{ print $4 }')
	new="$x/$one/$two/$three"
	output="devuan.iso"
	checkfile $1
}

jingosurl() {
	mirror="https://download.jingos.com/os/JingOS-V0.9-a25ea3.iso"
	new="$mirror"
	output="jingos.iso"
	checkfile $1
}

cutefishosurl() {
	mirror="https://sourceforge.net/projects/cutefish-ubuntu/files/latest/download"
	new="$mirror"
	output="cutefishos.iso"
	checkfile $1
}

parroturl() {
	mirror="https://deb.parrot.sh/direct/parrot/iso/testing/"
	x=$(curl -s $mirror | grep security | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -Eo ".+iso\$")
	new="$mirror$x"
	output="parrot.iso"
	checkfile $1
}

antixurl() {
	mirror="https://antixlinux.com/download/"
	x=$(curl "$mirror" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -E "sourceforge" | grep -E "runit" | grep -E "64" | grep -E "full")
	new="$x"
	output="antix.iso"
	checkfile $1
}

trisquelurl() {
	mirror="https://mirrors.ocf.berkeley.edu/trisquel-images/"
	iso=$(curl "$mirror" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -Eo ".+iso\$" | grep trisquel | tail -1)
	new="$mirror$iso"
	output="trisquel.iso"
	checkfile $1
}
peppermintosurl() {
	mirror="https://peppermintos.com/guide/downloading/"
	iso=$(curl "$mirror" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep iso | grep -i xfce | grep -i debian | head -1 | xargs)
	new="$iso"
	output="peppermintos-XFCE-Debian-base.iso"
	checkfile $1
}

nitruxurl() {
	mirror="https://sourceforge.net/projects/nitruxos/files/latest/download"
	iso=$(echo "$mirror")
	new="$iso"
	output="nitrux.iso"
	checkfile $1
}

damn_small_linux_url() {
	mirror="https://www.damnsmalllinux.org"
	dllink=$(curl https://www.damnsmalllinux.org/2024-download.html | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -v "txt" | grep iso | head -1)
	iso=$(echo "${mirror}${dllink}")
	new="$iso"
	output="damn_small_linux.iso"
	checkfile $1
}

vanillaos_url() {
	ver=$(curl "https://github.com/Vanilla-OS/live-iso" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | cut -d"/" -f6 | xargs)
	dllink=$(curl https://github.com/Vanilla-OS/live-iso/releases | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep "${ver}" | grep -v "txt" | grep ".*\.iso\$")
	iso=$(echo "${dllink}")
	new="$iso"
	output="vanilla_os_${ver}.iso"
	checkfile $1
}

tailsurl() {
	mirror="https://mirrors.edge.kernel.org/tails/stable/"
	version=$(curl -s $mirror | grep -o 'tails-amd64-[0-9.]*' | head -n1)
	x="https://mirrors.edge.kernel.org/tails/stable/${version}/${version}.img"
	new="$x"
	output="tailsos.img"
	checkfile $1
}

fedoraurl() {
	mirror="https://fedoraproject.org/workstation/download"
	new=$(curl -sSL "$mirror" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep iso | grep x86_64)
	output="fedora.iso"
	checkfile $1
}

centosurl() {
	mirror="https://www.centos.org/centos-stream/"
	x=$(curl -s $mirror | grep -m1 x86_64 | awk -F"\"" '{ print $2 }' | awk -F"&amp" '{ print $1 }')
	new=$(curl $x | grep https -m1)
	output="centos.iso"
	notlive
	checkfile $1
}

suseurl() {
	mirror="https://get.opensuse.org/tumbleweed/#download"
	new=$(curl -s $mirror | grep -m1 Current.iso | awk -F"\"" '{ print $2 }' | awk -F"\"" '{ print $1 }')
	output="opensuse.iso"
	checkfile $1
}

rosaurl() {
	mirror="https://www.rosalinux.ru/rosa-linux-download-links/"
	new=$(curl -s $mirror | html2text | grep -m1 "64-bit ISO" | awk -F"(" '{ print $2 }' | awk -F" " '{ print $1 }')
	output="rosa.iso"
	checkfile $1
}

mandrivaurl() {
	mirror="https://sourceforge.net/projects/openmandriva/files/latest/download"
	new="$mirror"
	output="mandriva.iso"
	checkfile $1
}

mageiaurl() {
	mirror="https://mirror.yandex.ru/mageia/iso/cauldron/"
	one=$(curl -s $mirror | grep Live-Xfce-x86_64 | awk -F"\"" '{ print $2 }')
	two=$(curl -s $mirror/$one | grep -m1 "x86_64.iso" | awk -F"\"" '{ print $2 }')
	new="$mirror/$one/$two"
	output="mageia.iso"
	checkfile $1
}

clearosurl() {
	mirror="https://www.clearos.com/products/purchase/clearos-downloads"
	one=$(curl -s $mirror | grep -m1 ".iso\"")
	two=${one%.iso*}
	two=${two#*http://}.iso
	link="https://$two"
	new=$(curl -s "$link" | grep window.open | awk -F\' '{ print $2 }')
	#new="$(cat ClearOS*iso | grep -m1 .iso | awk -F\' '{ print $2 }')"
	output="clearos.iso"
	#rm ${two#*http://}.iso
	notlive
	checkfile $1
}

almaurl() {
	mirror="https://mirrors.almalinux.org"
	x=$(curl -s "$mirror/isos.html" | grep x86_64 | tail -1 | awk -F"\"" '{ print $2 }')
	one=$(curl -s "$mirror/$x" | grep iso | wc -l)
	two=$(($RANDOM % $one + 1))
	three=$(curl -s "$mirror/$x" | grep iso | head -n$two | tail -1 | awk -F"\"" '{ print $2 }')
	four=$(curl -s "$three/" | grep -m1 dvd.iso | html2text | grep -m1 iso | awk -F"AlmaLinux" '{ print $2 }' | awk -F".iso" '{ print $1 }')
	new="$three/AlmaLinux$four.iso"
	output="alma.iso"
	checkfile $1
}

rockyurl() {
	mirror="https://rockylinux.org/download"
	new=$(curl "$mirror" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep iso | grep -v -e "CHECKSUM" | fzf)
	output="rocky.iso"
	checkfile $1
}

qubesurl() {
	mirror="https://www.qubes-os.org/downloads/"
	new=$(curl -s $mirror | grep -m1 x86_64.iso | awk -F"\"" '{ print $4 }')
	output="qubes.iso"
	checkfile $1
}

nobaraurl() {
	mirror="https://nobaraproject.org/download-nobara/"
	new=$(curl -s $mirror | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -E "KDE" | grep -E "iso" | head -1 | xargs)
	output="nobara.iso"
	checkfile $1
}

ultraurl() {
	mirror="https://ultramarine-linux.org/download/"
	new=$(curl -s $mirror | grep -m1 "Download Flagship" | awk -F"\"" '{ print $14 }')
	output="ultramarine.iso"
	checkfile $1
}

springurl() {
	mirror="https://springdale.math.ias.edu/#Mirrors"
	new=$(curl -s $mirror | grep -m1 "/boot.iso" | awk -F"\"" '{ print $4 }')
	output="springdale.iso"
	checkfile $1
}

berryurl() {
	mirror="https://berry-lab.net/edownload.html"
	new=$(curl -s $mirror | grep -m1 .iso | awk -F"\"" '{ print $2 }')
	output="berry.iso"
	checkfile $1
}

risiurl() {
	mirror="https://risi.io/#download"
	new=$(curl -s $mirror | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -E "mirror" | tail -1)
	output="risios.iso"
	checkfile $1
}

eurourl() {
	mirror="https://fbi.cdn.euro-linux.com/isos/"
	x=$(curl -s $mirror | grep latest.iso | awk -F"\"" '{ print $2 }')
	new="$mirror$x"
	output="eurolinux.iso"
	checkfile $1
}

alpineurl() {
	mirrorone="https://alpinelinux.org/downloads/"
	one=$(curl -s $mirrorone | grep Current | awk -F">" '{ print $3 }' | awk -F"<" '{ print $1 }')
	shortv=$(echo $one | awk -F"." '{ print $1"."$2}')
	x="http://dl-cdn.alpinelinux.org/alpine/v$shortv/releases/x86_64/alpine-extended-$one-x86_64.iso"
	new="$x"
	output="alpine.iso"
	checkfile $1
}

tinycoreurl() {
	mirrorone="http://tinycorelinux.net/downloads.html"
	one=$(curl -s $mirrorone | grep TinyCore-current.iso | awk -F\" '{ print $2 }')
	mirror="http://tinycorelinux.net/"
	new="$mirror/$one"
	output="tinycore.iso"
	checkfile $1
}

porteusurl() {
	mirrorone="https://porteus-kiosk.org/download.html"
	one=$(curl -s $mirrorone | grep "Porteus-Kiosk.*x86_64.iso" | grep -m1 public | awk -F\" '{ print $2 }')
	mirror="https://porteus-kiosk.org/"
	new="$mirror/$one"
	output="porteus.iso"
	checkfile $1
}

slitazurl() {
	x="http://mirror.slitaz.org/iso/rolling/slitaz-rolling-core64.iso"
	new="$x"
	output="slitaz.iso"
	checkfile $1
}

pclinuxosurl() {
	mirror="http://ftp.nluug.nl/pub/os/Linux/distr/pclinuxos/pclinuxos/live-cd/64bit/"
	x="pclinuxos$(curl -s $mirror | grep -m1 .iso | awk -F"pclinuxos" '{ print $2 }' | awk -F\" '{ print $1 }')"
	new="$mirror$x"
	output="pclinuxos.iso"
	checkfile $1
}

voidurl() {
	mirror="https://alpha.de.repo.voidlinux.org/live/current/"
	x=$(curl -s $mirror | grep "xfce" | grep -m1 "musl" | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }')
	new="$mirror/$x"
	output="void.iso"
	checkfile $1
}

fourmurl() {
	mirror="https://sourceforge.net/projects/linux4m/files/latest/download"
	new="$mirror"
	output="4mlinux.iso"
	checkfile $1
}

kaosurl() {
	mirror="https://sourceforge.net/projects/kaosx/files/latest/download"
	new="$mirror"
	output="kaos.iso"
	checkfile $1
}

clearurl() {
	mirror="https://www.clearlinux.org/downloads.html"
	ver=$(curl "$mirror" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep live | grep iso | cut -d"/" -f5 | sort | uniq | xargs)
	new="https://cdn.download.clearlinux.org/releases/$ver/clear/clear-$ver-live-desktop.iso"
	output="clearlinux.iso"
	checkfile $1
}

dragoraurl() {
	getVer=$(curl https://mirror.fsf.org/dragora/current/iso/ | grep -E "beta" | tail -1 | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | tr -d "/")
	mirror="https://mirror.fsf.org/dragora/current/iso/${getVer}/"
	x=$(curl "${mirror}" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | tail -3 | head -1)
	new="$mirror$x"
	output="dragora.iso"
	checkfile $1
}

slackwareurl() {
	mirror="https://mirrors.slackware.com/slackware/slackware-iso/"
	x=$(curl -s $mirror | grep slackware64 | tail -1 | awk -F"slack" '{ print $2 }' | awk -F"/" '{ print $1 }')
	other="slack$x"
	y=$(curl -s "$mirror/$other/" | grep dvd.iso | head -1 | awk -F"slack" '{ print $2 }' | awk -F\" '{ print $1 }')
	new="$mirror"
	new+="$other"
	new+="/slack"
	new+="$y"
	echo "new=$new"
	output="slackware.iso"
	checkfile $1
}

adelieurl() {
	mirror="https://www.adelielinux.org/download/"
	x=$(curl -s $mirror | html2text | grep "Listing]" | awk -F"(" '{ print $2 }' | awk -F")" '{ print $1 }')
	y=$(curl -s $x | grep live-mate | grep -m1 "x86_64" | awk -F"\"" '{ print $2 }')
	new="$x$y"
	output="adelie.iso"
	checkfile $1
}

plopurl() {
	mirror="https://www.plop.at/en/ploplinux/downloads/full.html"
	x="$(curl -s $mirror | grep x86_64.iso | head -1 | awk -F"https://" '{ print $2 }' | awk -F".iso" '{ print $1 }')"
	new="https://$x.iso"
	output="plop.iso"
	checkfile $1
}

solusurl() {
	mirror="https://getsol.us/download/"
	x=$(curl -s "$mirror" | grep -E "download" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -E "Budgie" | head -1 | grep -Eo "https.+iso")
	new="$x"
	output="solus.iso"
	checkfile $1
}

peropesisurl() {
	mirror="https://peropesis.org"
	mirror2="$mirror/get-peropesis/"
	x=$(curl -s $mirror2 | grep -m1 "live.iso" | awk -F"\"" '{ print $8 }')
	new="$mirror$x"
	output="peropesis.iso"
	checkfile $1
}

openmambaurl() {
	mirror="https://openmamba.org/en/downloads/"
	new=$(curl -s $mirror | grep "rolling livedvd" | awk -F"href" '{ print $2 }' | awk -F"\"" '{ print $2 }')
	output="openmamba.iso"
	checkfile $1
}

pisiurl() {
	new="https://sourceforge.net/projects/pisilinux/files/latest/download"
	output="pisi.iso"
	checkfile $1
}

###################################

gentoourl() {
	mirror="https://gentoo.c3sl.ufpr.br//releases/amd64/autobuilds"
	one=$(curl -s "$mirror/latest-iso.txt" | grep "admin" | awk '{ print $1 }')
	new="$mirror/$one"
	output="gentoo.iso"
	notlive
	checkfile $1
}

calcurl() {
	mirror="http://mirror.yandex.ru/calculate/nightly/"
	x=$(curl -s $mirror | grep "<a" | tail -1 | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }')
	mirror+=$x
	x=$(curl -s $mirror | grep -m1 cldc | awk -F\" '{ print $2 }')
	new="$mirror$x"
	output="calculate.iso"
	checkfile $1
}

nixurl() {
	mirror="https://channels.nixos.org/nixos-unstable"
	saved=$(curl -sL $mirror)
	dir=$(echo $saved | awk -F"nixos" '{ print $26 }')
	file=$(echo $saved | awk -F"nixos" '{ print $28 }' | awk -F".iso" '{ print $1 }')
	result="nixos"
	result+=$dir
	result+="nixos"
	result+=$file
	x="https://releases.nixos.org/nixos/unstable/$result.iso"
	new="$x"
	output="nixos.iso"
	notlive
	checkfile $1
}

guixurl() {
	mirror="https://guix.gnu.org/en/download/"
	x=$(curl -s $mirror | grep ".iso" | awk -F"https://" '{ print $2 }' | awk -F\" '{ print $1 }')
	new="https://$x"
	output="guix.iso.xz"
	notlive
	checkfile $1
	[ -f "guix.iso" ] && echo "Please wait, unpacking guix..." && xz -k -d -v ./guix*xz && mv guix*iso guix.iso
}

cruxurl() {
	mirror="http://ftp.morpheus.net/pub/linux/crux/latest/iso/"
	x=$(curl -s $mirror | grep iso | grep href | awk -F"\"" '{ print $6 }' | awk -F"\"" '{ print $1 }')
	new="$mirror$x"
	output="crux.iso"
	checkfile $1
}

gobourl() {
	mirror="https://api.github.com/repos/gobolinux/LiveCD/releases/latest"
	new=$(curl -s $mirror | grep browser_download_url | grep x86_64.iso | awk -F"\"" '{ print $4 }')
	output="gobolinux.iso"
	checkfile $1
}

easyurl() {
	mirror="https://distro.ibiblio.org/easyos/amd64/releases/dunfell/2023/"
	x=$(curl -s $mirror | grep "Directory<" | tail -1 | awk -F "\"" '{ print $6 }')
	y=$(curl -s $mirror$x | grep img | awk -F"\"" '{ print $4 }')
	new="$mirror$x$y"
	output="easyos.img"
	checkfile $1
}

####################################

rancherurl() {
	mirror="https://api.github.com/repos/rancher/os/releases/latest"
	new=$(curl -s $mirror | grep browser_download_url | grep rancheros.iso | awk -F"\"" '{ print $4 }')
	output="rancheros.iso"
	checkfile $1
}

k3osurl() {
	mirror="https://api.github.com/repos/rancher/k3os/releases/latest"
	new=$(curl -s $mirror | grep browser_download_url | grep k3os-amd64.iso | awk -F"\"" '{ print $4 }')
	output="k3os.iso"
	checkfile $1
}

flatcarurl() {
	mirror="https://alpha.release.flatcar-linux.net/amd64-usr/current/flatcar_production_iso_image.iso"
	new="$mirror"
	output="flatcar.iso"
	checkfile $1
}

silverblueurl() {
	mirror="https://silverblue.fedoraproject.org/download"
	x=$(curl -s $mirror | grep -m1 x86_64 | awk -F\' '{ print $2 }')
	new="$x"
	output="silverblue.iso"
	checkfile $1
}

photonurl() {
	mirror="https://github.com/vmware/photon/wiki/Downloading-Photon-OS"
	x=$(curl -s $mirror | grep -m1 "Full ISO" | awk -F\" '{ print $2 }')
	new="$x"
	output="photonos.iso"
	notlive
	checkfile $1
}

coreosurl() {
	mirror="https://builds.coreos.fedoraproject.org/streams/next.json"
	x=$(curl -s $mirror | grep iso | grep -m1 location | awk -F\" '{ print $4 }')
	new="$x"
	output="coreos.iso"
	checkfile $1
}

dcosurl() {
	new="https://downloads.dcos.io/dcos/stable/dcos_generate_config.sh"
	output="dcos_generate_config.sh"
	echo "Warning! This is not an ISO or disk image, but rather a OS generator tool. After downloading, run chmod +x ./dc*sh"
	checkfile $1
}

freebsdurl() {
	mirror="https://www.freebsd.org/where/"
	x=$(curl -s $mirror | grep -m1 "amd64/amd64" | awk -F\" '{ print $2 }')
	one=$(curl -s $x | grep -m1 dvd1 | awk -F"FreeBSD" '{ print $2 }' | awk -F\" '{ print $1 }')
	new=$x
	new+="FreeBSD"
	new+=$one
	output="freebsd.iso"
	notlinux
	checkfile $1
}

netbsdurl() {
	mirror="https://www.netbsd.org/"
	#mirror="https://wiki.netbsd.org/ports/amd64/"
	new=$(curl -s $mirror | grep -m1 "CD" | awk -F\" '{ print $4 }')
	output="netbsd.iso"
	notlinux
	checkfile $1
}

openbsdurl() {
	mirror="https://www.openbsd.org/faq/faq4.html#Download"
	new=$(curl -s $mirror | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep "amd64" | grep "iso" | head -1)
	output="openbsd.iso"
	notlinux
	checkfile $1
}

ghostbsdurl() {
	mirror="http://download.fr.ghostbsd.org/development/amd64/latest/"
	x=$(curl -s -L $mirror | grep ".iso<" | head -1 | awk -F\" '{ print $2 }')
	new="$mirror$x"
	output="ghostbsd.iso"
	notlinux
	checkfile $1
}

hellosystemurl() {
	#mirror="https://github.com/helloSystem/ISO/releases/download/r0.5.0/hello-0.5.0_0E223-FreeBSD-12.2-amd64.iso"
	#mirror="https://github.com/helloSystem/ISO/releases/latest"
	#x=$(curl -s -L $mirror | grep FreeBSD | grep -m1 iso | awk -F\" '{ print $2 }')
	#new="https://github.com$x"
	mirror="https://api.github.com/repos/helloSystem/ISO/releases/latest"
	new=$(curl -s $mirror | grep browser_download_url | grep -m1 amd64.iso | awk -F"\"" '{ print $4 }')
	output="hellosystem.iso"
	notlinux
	checkfile $1
}

dragonurl() {
	mirror="https://www.dragonflybsd.org/download/"
	new=$(curl -s $mirror | grep "Uncompressed ISO:" | awk -F"\"" '{ print $2 }')
	output="dragonflybsd.iso"
	notlinux
	checkfile $1
}

pfsenseurl() {
	mirror="https://atxfiles.netgate.com/mirror/downloads/"
	x=$(curl -s $mirror | grep "amd64.iso.gz</a>" | tail -1 | awk -F"\"" '{ print $2 }')
	new="$mirror$x"
	output="pfsense.iso.gz"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[ ! -f $output ] && download && echo "Please wait, unpacking pfSense..." && gzip -d $output || echo "pfSense already downloaded."
	fi
}

opnsenseurl() {
	mirror="https://mirror.terrahost.no/opnsense/releases/"
	x=$(curl -s $mirror | grep -B1 mirror | head -1 | awk -F"\"" '{ print $2 }')
	y=$(curl -s $mirror$x | grep -m1 dvd | awk -F"\"" '{ print $2 }')
	new="$mirror$x$y"
	output="opnsense.iso.bz2"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[ ! -f $output ] && download && echo "Please wait, unpacking opnsense..." && bzip2 -k -d $output && rm $output || echo "OpnSense already downloaded."
	fi
}

midnightbsdurl() {
	mirror="https://discovery.midnightbsd.org/releases/amd64/ISO-IMAGES/"
	x=$(curl -s $mirror | grep href | tail -1 | awk -F"\"" '{ print $2 }')
	y=$(curl -s $mirror$x | grep disc1.iso | awk -F"\"" '{ print $2 }')
	new="$mirror$x$y"
	output="midnightbsd.iso"
	notlinux
	checkfile $1
}

truenasurl() {
	mirror="https://www.truenas.com/download-truenas-core/"
	new=$(curl -s $mirror | grep -m1 iso | awk -F"\"" '{ print $6 }')
	output="truenas.iso"
	notlinux
	checkfile $1
}

nomadbsdurl() {
	mirror="https://nomadbsd.org/download.html"
	new=$(curl -s $mirror | grep -A2 "Main site" | grep -m1 img.lzma | awk -F"\"" '{ print $2 }')
	output="nomadbsd.img.lzma"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[[ ! -f $output && ! -f "nomadbsd.img" ]] && download && echo "Please wait, unpacking NomadBSD..." && lzma -d $output || echo "NomadBSD already downloaded."
	fi
}

hardenedbsdurl() {
	new="https://installers.hardenedbsd.org/pub/current/amd64/amd64/installer/LATEST/disc1.iso"
	output="hardenedbsd.iso"
	notlinux
	checkfile $1
}

xigmanasurl() {
	new="https://sourceforge.net/projects/xigmanas/files/latest/download"
	output="xigmanas.iso"
	notlinux
	checkfile $1
}

clonosurl() {
	mirror="https://clonos.convectix.com/download.html"
	new=$(curl -s $mirror | grep .iso | awk -F"\"" '{ print $2 }')
	output="clonos.iso"
	notlinux
	checkfile $1
}

## Not Linux

indianaurl() {
	mirror="https://www.openindiana.org/download/"
	x=$(curl -s $mirror | grep "Live DVD" | awk -F"http://" '{ print $2 }' | awk -F\" '{ print $1 }')
	new="http://$x"
	output="openindiana.iso"
	notlinux
	checkfile $1
}

minixurl() {
	mirror="https://wiki.minix3.org/doku.php?id=www:download:start"
	x=$(curl -s $mirror | grep -m1 iso.bz2 | awk -F"http://" '{ print $2 }' | awk -F\" '{ print $1 }')
	new="http://$x"
	output="minix.iso.bz2"
	if [ "$1" == "filesize" ]; then
		notlinux
		notlive
		getsize
	else
		[ ! -f $output ] && download && echo "Please wait, unpacking minix..." && bzip2 -k -d $output || echo "Minix already downloaded."
	fi
}

haikuurl() {
	mirror="https://download.haiku-os.org/nightly-images/x86_64/"
	x=$(curl -s $mirror | grep -m1 zip | awk -F\" '{ print $2 }')
	new="$x"
	output="haiku.zip"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[ ! -f $output ] && download && echo "Please wait, unzipping haiku..." && unzip $output && rm ReadMe.md && mv haiku*iso haiku.iso || echo "Haiku already downloaded."
	fi
}

menueturl() {
	mirror="http://www.menuetos.be/download.php?CurrentMenuetOS"
	new="$mirror"
	output="menuetos.zip"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[ ! -f $output ] && download && echo "Wait, unzipping menuetos..." && unzip $output && mv M64*.IMG menuetos.img || echo "Menuet already downloaded."
	fi
}

kolibriurl() {
	new="https://builds.kolibrios.org/eng/latest-iso.7z"
	output="kolibrios.7z"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[[ ! -f $output && ! -f "kolibri.iso" ]] && download && echo "Un7zipping kolibri..." && 7z x $output && sleep 7 && rm $output && rm "INSTALL.TXT" || echo "Kolibri already downloaded."
	fi
}

reactosurl() {
	new="https://sourceforge.net/projects/reactos/files/latest/download"
	output="reactos.zip"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[[ ! -f $output && ! -f "reactos.iso" ]] && download && echo "Please wait, unzipping reactos..." && unzip $output && mv React*iso reactos.iso || echo "ReactOS already downloaded."
	fi
}

freedosurl() {
	#mirror="https://sourceforge.net/projects/freedos/files/latest/download"
	#mirror="https://www.freedos.org/download/download/FD12CD.iso"
	mirror="https://www.freedos.org/download/"
	new=$(curl -s $mirror | grep FD13-LiveCD.zip | awk -F"\"" '{ print $2 }')
	output="freedos.zip"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[[ ! -f $output && ! -f "freedos.img" ]] && download && echo "Please wait, unzipping FreeDOS..." && unzip $output && sleep 10 && rm $output && rm readme.txt && mv FD13BOOT.img freedos.img && mv FD13LIVE.iso freedos.iso || echo "FreeDOS already downloaded."
	fi
}

netbootxyz() {
	mirror="https://boot.netboot.xyz/ipxe/netboot.xyz.iso"
	new="$mirror"
	output="netboot.xyz.iso"
	checkfile $1
}

netbootsal() {
	mirror="http://boot.salstar.sk/ipxe/ipxe.iso"
	new="$mirror"
	output="ipxe.iso"
	checkfile $1
}

# this one is currently broken
netbootipxe() {
	#mirror="http://cloudboot.nchc.org.tw/cloudboot/cloudboot_img/cloudboot_1.0.iso"
	mirror="http://boot.ipxe.org/ipxe.iso"
	new="$mirror"
	output="bootipxe.iso"
	checkfile $1
}

## Windows

unattended_windows() {
	cat <<'EOF' >"${1}"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
                    <!--https://schneegans.de/windows/unattend-generator/?LanguageMode=Unattended&UILanguage=en-US&Locale=en-001&Keyboard=00000409&GeoLocation=244&ProcessorArchitecture=amd64&BypassRequirementsCheck=true&BypassNetworkCheck=true&ComputerNameMode=Random&CompactOsMode=Default&TimeZoneMode=Implicit&PartitionMode=Unattended&PartitionLayout=GPT&EspSize=300&RecoveryMode=None&DiskAssertionMode=Skip&WindowsEditionMode=Generic&WindowsEdition=pro&InstallFromMode=Automatic&PEMode=Default&UserAccountMode=Unattended&AccountName0=Admin&AccountDisplayName0=&AccountPassword0=&AccountGroup0=Administrators&AccountName1=<USERNAME_HERE>&AccountDisplayName1=<USERNAME_HERE>&AccountPassword1=&AccountGroup1=Users&AutoLogonMode=None&ObscurePasswords=true&PasswordExpirationMode=Unlimited&LockoutMode=Default&HideFiles=Hidden&ShowFileExtensions=true&ClassicContextMenu=true&LaunchToThisPC=true&ShowEndTask=true&TaskbarSearch=Hide&TaskbarIconsMode=Default&DisableWidgets=true&LeftTaskbar=true&DisableBingResults=true&StartTilesMode=Empty&StartPinsMode=Empty&EnableLongPaths=true&HideEdgeFre=true&DisableEdgeStartupBoost=true&MakeEdgeUninstallable=true&DisablePointerPrecision=true&DeleteWindowsOld=true&EffectsMode=Default&DesktopIconsMode=Default&WifiMode=Interactive&ExpressSettings=DisableAll&KeysMode=Skip&StickyKeysMode=Default&ColorMode=Custom&SystemColorTheme=Dark&AppsColorTheme=Dark&AccentColor=%230078d4&WallpaperMode=Default&Remove3DViewer=true&RemoveBingSearch=true&RemoveCamera=true&RemoveClipchamp=true&RemoveCopilot=true&RemoveCortana=true&RemoveDevHome=true&RemoveFamily=true&RemoveFeedbackHub=true&RemoveGetHelp=true&RemoveHandwriting=true&RemoveInternetExplorer=true&RemoveMailCalendar=true&RemoveMaps=true&RemoveMathInputPanel=true&RemoveMediaFeatures=true&RemoveMixedReality=true&RemoveZuneVideo=true&RemoveNews=true&RemoveOffice365=true&RemoveOneDrive=true&RemoveOneNote=true&RemoveOneSync=true&RemoveOutlook=true&RemovePowerAutomate=true&RemoveQuickAssist=true&RemoveRecall=true&RemoveSnippingTool=true&RemoveSolitaire=true&RemoveStepsRecorder=true&RemoveStickyNotes=true&RemoveTeams=true&RemoveGetStarted=true&RemoveToDo=true&RemoveVoiceRecorder=true&RemoveWallet=true&RemoveWeather=true&RemoveWindowsHello=true&RemoveYourPhone=true&WdacMode=Skip-->
	<settings pass="offlineServicing"></settings>
	<settings pass="windowsPE">
		<component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
			<SetupUILanguage>
				<UILanguage>en-US</UILanguage>
			</SetupUILanguage>
			<InputLocale>0409:00000409</InputLocale>
			<SystemLocale>en-001</SystemLocale>
			<UILanguage>en-US</UILanguage>
			<UserLocale>en-001</UserLocale>
		</component>
		<component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
			<ImageInstall>
				<OSImage>
					<InstallTo>
						<DiskID>0</DiskID>
						<PartitionID>3</PartitionID>
					</InstallTo>
				</OSImage>
			</ImageInstall>
			<UserData>
				<ProductKey>
					<Key>VK7JG-NPHTM-C97JM-9MPGT-3V66T</Key>
					<WillShowUI>OnError</WillShowUI>
				</ProductKey>
				<AcceptEula>true</AcceptEula>
			</UserData>
			<UseConfigurationSet>false</UseConfigurationSet>
			<RunSynchronous>
				<RunSynchronousCommand wcm:action="add">
					<Order>1</Order>
					<Path>cmd.exe /c "&gt;&gt;"X:\diskpart.txt" (echo SELECT DISK=0&amp;echo CLEAN&amp;echo CONVERT GPT&amp;echo CREATE PARTITION EFI SIZE=300&amp;echo FORMAT QUICK FS=FAT32 LABEL="System"&amp;echo CREATE PARTITION MSR SIZE=16)"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>2</Order>
					<Path>cmd.exe /c "&gt;&gt;"X:\diskpart.txt" (echo CREATE PARTITION PRIMARY&amp;echo FORMAT QUICK FS=NTFS LABEL="Windows")"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>3</Order>
					<Path>cmd.exe /c "diskpart.exe /s "X:\diskpart.txt" &gt;&gt;"X:\diskpart.log" || ( type "X:\diskpart.log" &amp; echo diskpart encountered an error. &amp; pause &amp; exit /b 1 )"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>4</Order>
					<Path>reg.exe add "HKLM\SYSTEM\Setup\LabConfig" /v BypassTPMCheck /t REG_DWORD /d 1 /f</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>5</Order>
					<Path>reg.exe add "HKLM\SYSTEM\Setup\LabConfig" /v BypassSecureBootCheck /t REG_DWORD /d 1 /f</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>6</Order>
					<Path>reg.exe add "HKLM\SYSTEM\Setup\LabConfig" /v BypassRAMCheck /t REG_DWORD /d 1 /f</Path>
				</RunSynchronousCommand>
			</RunSynchronous>
		</component>
	</settings>
	<settings pass="generalize"></settings>
	<settings pass="specialize">
		<component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
			<RunSynchronous>
				<RunSynchronousCommand wcm:action="add">
					<Order>1</Order>
					<Path>powershell.exe -WindowStyle Normal -NoProfile -Command "$xml = [xml]::new(); $xml.Load('C:\Windows\Panther\unattend.xml'); $sb = [scriptblock]::Create( $xml.unattend.Extensions.ExtractScript ); Invoke-Command -ScriptBlock $sb -ArgumentList $xml;"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>2</Order>
					<Path>powershell.exe -WindowStyle Normal -NoProfile -Command "Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\Specialize.ps1' -Raw | Invoke-Expression;"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>3</Order>
					<Path>reg.exe load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>4</Order>
					<Path>powershell.exe -WindowStyle Normal -NoProfile -Command "Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\DefaultUser.ps1' -Raw | Invoke-Expression;"</Path>
				</RunSynchronousCommand>
				<RunSynchronousCommand wcm:action="add">
					<Order>5</Order>
					<Path>reg.exe unload "HKU\DefaultUser"</Path>
				</RunSynchronousCommand>
			</RunSynchronous>
		</component>
	</settings>
	<settings pass="auditSystem"></settings>
	<settings pass="auditUser"></settings>
	<settings pass="oobeSystem">
		<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
			<InputLocale>0409:00000409</InputLocale>
			<SystemLocale>en-001</SystemLocale>
			<UILanguage>en-US</UILanguage>
			<UserLocale>en-001</UserLocale>
		</component>
		<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
			<UserAccounts>
				<LocalAccounts>
					<LocalAccount wcm:action="add">
						<Name>Admin</Name>
						<DisplayName></DisplayName>
						<Group>Administrators</Group>
						<Password>
							<Value>UABhAHMAcwB3AG8AcgBkAA==</Value>
							<PlainText>false</PlainText>
						</Password>
					</LocalAccount>
					<LocalAccount wcm:action="add">
                        <Name><USERNAME_HERE></Name>
                        <DisplayName><USERNAME_HERE></DisplayName>
						<Group>Users</Group>
						<Password>
							<Value>UABhAHMAcwB3AG8AcgBkAA==</Value>
							<PlainText>false</PlainText>
						</Password>
					</LocalAccount>
				</LocalAccounts>
			</UserAccounts>
			<OOBE>
				<ProtectYourPC>3</ProtectYourPC>
				<HideEULAPage>true</HideEULAPage>
				<HideWirelessSetupInOOBE>false</HideWirelessSetupInOOBE>
				<HideOnlineAccountScreens>false</HideOnlineAccountScreens>
			</OOBE>
			<FirstLogonCommands>
				<SynchronousCommand wcm:action="add">
					<Order>1</Order>
					<CommandLine>powershell.exe -WindowStyle Normal -NoProfile -Command "Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\FirstLogon.ps1' -Raw | Invoke-Expression;"</CommandLine>
				</SynchronousCommand>
			</FirstLogonCommands>
		</component>
	</settings>
	<Extensions xmlns="https://schneegans.de/windows/unattend-generator/">
		<ExtractScript>
param(
    [xml] $Document
);

foreach( $file in $Document.unattend.Extensions.File ) {
    $path = [System.Environment]::ExpandEnvironmentVariables( $file.GetAttribute( 'path' ) );
    mkdir -Path( $path | Split-Path -Parent ) -ErrorAction 'SilentlyContinue';
    $encoding = switch( [System.IO.Path]::GetExtension( $path ) ) {
        { $_ -in '.ps1', '.xml' } { [System.Text.Encoding]::UTF8; }
        { $_ -in '.reg', '.vbs', '.js' } { [System.Text.UnicodeEncoding]::new( $false, $true ); }
        default { [System.Text.Encoding]::Default; }
    };
    $bytes = $encoding.GetPreamble() + $encoding.GetBytes( $file.InnerText.Trim() );
    [System.IO.File]::WriteAllBytes( $path, $bytes );
}
		</ExtractScript>
		<File path="C:\Windows\Setup\Scripts\RemovePackages.ps1">
$selectors = @(
	'Microsoft.Microsoft3DViewer';
	'Microsoft.BingSearch';
	'Microsoft.WindowsCamera';
	'Clipchamp.Clipchamp';
	'Microsoft.549981C3F5F10';
	'Microsoft.Windows.DevHome';
	'MicrosoftCorporationII.MicrosoftFamily';
	'Microsoft.WindowsFeedbackHub';
	'Microsoft.GetHelp';
	'Microsoft.Getstarted';
	'microsoft.windowscommunicationsapps';
	'Microsoft.WindowsMaps';
	'Microsoft.MixedReality.Portal';
	'Microsoft.BingNews';
	'Microsoft.MicrosoftOfficeHub';
	'Microsoft.Office.OneNote';
	'Microsoft.OutlookForWindows';
	'Microsoft.PowerAutomateDesktop';
	'MicrosoftCorporationII.QuickAssist';
	'Microsoft.ScreenSketch';
	'Microsoft.MicrosoftSolitaireCollection';
	'Microsoft.MicrosoftStickyNotes';
	'MicrosoftTeams';
	'MSTeams';
	'Microsoft.Todos';
	'Microsoft.WindowsSoundRecorder';
	'Microsoft.Wallet';
	'Microsoft.BingWeather';
	'Microsoft.YourPhone';
	'Microsoft.ZuneVideo';
);
$getCommand = {
  Get-AppxProvisionedPackage -Online;
};
$filterCommand = {
  $_.DisplayName -eq $selector;
};
$removeCommand = {
  [CmdletBinding()]
  param(
    [Parameter( Mandatory, ValueFromPipeline )]
    $InputObject
  );
  process {
    $InputObject | Remove-AppxProvisionedPackage -AllUsers -Online -ErrorAction 'Continue';
  }
};
$type = 'Package';
$logfile = 'C:\Windows\Setup\Scripts\RemovePackages.log';
&amp; {
	$installed = &amp; $getCommand;
	foreach( $selector in $selectors ) {
		$result = [ordered] @{
			Selector = $selector;
		};
		$found = $installed | Where-Object -FilterScript $filterCommand;
		if( $found ) {
			$result.Output = $found | &amp; $removeCommand;
			if( $? ) {
				$result.Message = "$type removed.";
			} else {
				$result.Message = "$type not removed.";
				$result.Error = $Error[0];
			}
		} else {
			$result.Message = "$type not installed.";
		}
		$result | ConvertTo-Json -Depth 3 -Compress;
	}
} *&gt;&amp;1 &gt;&gt; $logfile;
		</File>
		<File path="C:\Windows\Setup\Scripts\RemoveCapabilities.ps1">
$selectors = @(
	'Language.Handwriting';
	'Browser.InternetExplorer';
	'MathRecognizer';
	'OneCoreUAP.OneSync';
	'App.Support.QuickAssist';
	'Microsoft.Windows.SnippingTool';
	'App.StepsRecorder';
	'Hello.Face.18967';
	'Hello.Face.Migration.18967';
	'Hello.Face.20134';
);
$getCommand = {
  Get-WindowsCapability -Online | Where-Object -Property 'State' -NotIn -Value @(
    'NotPresent';
    'Removed';
  );
};
$filterCommand = {
  ($_.Name -split '~')[0] -eq $selector;
};
$removeCommand = {
  [CmdletBinding()]
  param(
    [Parameter( Mandatory, ValueFromPipeline )]
    $InputObject
  );
  process {
    $InputObject | Remove-WindowsCapability -Online -ErrorAction 'Continue';
  }
};
$type = 'Capability';
$logfile = 'C:\Windows\Setup\Scripts\RemoveCapabilities.log';
&amp; {
	$installed = &amp; $getCommand;
	foreach( $selector in $selectors ) {
		$result = [ordered] @{
			Selector = $selector;
		};
		$found = $installed | Where-Object -FilterScript $filterCommand;
		if( $found ) {
			$result.Output = $found | &amp; $removeCommand;
			if( $? ) {
				$result.Message = "$type removed.";
			} else {
				$result.Message = "$type not removed.";
				$result.Error = $Error[0];
			}
		} else {
			$result.Message = "$type not installed.";
		}
		$result | ConvertTo-Json -Depth 3 -Compress;
	}
} *&gt;&amp;1 &gt;&gt; $logfile;
		</File>
		<File path="C:\Windows\Setup\Scripts\RemoveFeatures.ps1">
$selectors = @(
	'MediaPlayback';
	'Recall';
	'Microsoft-SnippingTool';
);
$getCommand = {
  Get-WindowsOptionalFeature -Online | Where-Object -Property 'State' -NotIn -Value @(
    'Disabled';
    'DisabledWithPayloadRemoved';
  );
};
$filterCommand = {
  $_.FeatureName -eq $selector;
};
$removeCommand = {
  [CmdletBinding()]
  param(
    [Parameter( Mandatory, ValueFromPipeline )]
    $InputObject
  );
  process {
    $InputObject | Disable-WindowsOptionalFeature -Online -Remove -NoRestart -ErrorAction 'Continue';
  }
};
$type = 'Feature';
$logfile = 'C:\Windows\Setup\Scripts\RemoveFeatures.log';
&amp; {
	$installed = &amp; $getCommand;
	foreach( $selector in $selectors ) {
		$result = [ordered] @{
			Selector = $selector;
		};
		$found = $installed | Where-Object -FilterScript $filterCommand;
		if( $found ) {
			$result.Output = $found | &amp; $removeCommand;
			if( $? ) {
				$result.Message = "$type removed.";
			} else {
				$result.Message = "$type not removed.";
				$result.Error = $Error[0];
			}
		} else {
			$result.Message = "$type not installed.";
		}
		$result | ConvertTo-Json -Depth 3 -Compress;
	}
} *&gt;&amp;1 &gt;&gt; $logfile;
		</File>
		<File path="C:\Windows\Setup\Scripts\MakeEdgeUninstallable.ps1">
$ErrorActionPreference = 'Stop';
&amp; {
	try {
		$params = @{
			LiteralPath = 'C:\Windows\System32\IntegratedServicesRegionPolicySet.json';
			Encoding = 'Utf8';
		};
		$o = Get-Content @params | ConvertFrom-Json;
		$o.policies | ForEach-Object -Process {
			if( $_.guid -eq '{1bca278a-5d11-4acf-ad2f-f9ab6d7f93a6}' ) {
				$_.defaultState = 'enabled';
			}
		};
		$o | ConvertTo-Json -Depth 9 | Out-File @params;
	} catch {
		$_;
	}
} *&gt;&amp;1 &gt;&gt; 'C:\Windows\Setup\Scripts\MakeEdgeUninstallable.log';
		</File>
		<File path="C:\Windows\Setup\Scripts\SetStartPins.ps1">
$json = '{"pinnedList":[]}';
if( [System.Environment]::OSVersion.Version.Build -lt 20000 ) {
	return;
}
$key = 'Registry::HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start';
New-Item -Path $key -ItemType 'Directory' -ErrorAction 'SilentlyContinue';
Set-ItemProperty -LiteralPath $key -Name 'ConfigureStartPins' -Value $json -Type 'String';
		</File>
		<File path="C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml">
&lt;LayoutModificationTemplate Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"&gt;
	&lt;LayoutOptions StartTileGroupCellWidth="6" /&gt;
	&lt;DefaultLayoutOverride&gt;
		&lt;StartLayoutCollection&gt;
			&lt;StartLayout GroupCellWidth="6" xmlns="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" /&gt;
		&lt;/StartLayoutCollection&gt;
	&lt;/DefaultLayoutOverride&gt;
&lt;/LayoutModificationTemplate&gt;
		</File>
		<File path="C:\Windows\Setup\Scripts\SetColorTheme.ps1">
$lightThemeSystem = 0;
$lightThemeApps = 0;
$accentColorOnStart = 0;
$enableTransparency = 0;
$htmlAccentColor = '#0078D4';
&amp; {
	$params = @{
		LiteralPath = 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize';
		Force = $true;
		Type = 'DWord';
	};
	Set-ItemProperty @params -Name 'SystemUsesLightTheme' -Value $lightThemeSystem;
	Set-ItemProperty @params -Name 'AppsUseLightTheme' -Value $lightThemeApps;
	Set-ItemProperty @params -Name 'ColorPrevalence' -Value $accentColorOnStart;
	Set-ItemProperty @params -Name 'EnableTransparency' -Value $enableTransparency;
};
&amp; {
	Add-Type -AssemblyName 'System.Drawing';
	$accentColor = [System.Drawing.ColorTranslator]::FromHtml( $htmlAccentColor );

	function ConvertTo-DWord {
		param(
			[System.Drawing.Color]
			$Color
		);
						
		[byte[]] $bytes = @(
			$Color.R;
			$Color.G;
			$Color.B;
			$Color.A;
		);
		return [System.BitConverter]::ToUInt32( $bytes, 0); 
	}

	$startColor = [System.Drawing.Color]::FromArgb( 0xD2, $accentColor );
	Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'StartColorMenu' -Value( ConvertTo-DWord -Color $accentColor ) -Type 'DWord' -Force;
	Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent' -Name 'AccentColorMenu' -Value( ConvertTo-DWord -Color $accentColor ) -Type 'DWord' -Force;
	Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\DWM' -Name 'AccentColor' -Value( ConvertTo-DWord -Color $accentColor ) -Type 'DWord' -Force;
	$params = @{
		LiteralPath = 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent';
		Name = 'AccentPalette';
	};
	$palette = Get-ItemPropertyValue @params;
	$index = 20;
	$palette[ $index++ ] = $accentColor.R;
	$palette[ $index++ ] = $accentColor.G;
	$palette[ $index++ ] = $accentColor.B;
	$palette[ $index++ ] = $accentColor.A;
	Set-ItemProperty @params -Value $palette -Type 'Binary' -Force;
};
		</File>
		<File path="C:\Windows\Setup\Scripts\Specialize.ps1">
$scripts = @(
	{
		ReAgentc.exe /disable;
		Remove-Item -LiteralPath 'C:\Windows\System32\Recovery\Winre.wim' -Force -ErrorAction 'SilentlyContinue';
	};
	{
		reg.exe add "HKLM\SYSTEM\Setup\MoSetup" /v AllowUpgradesWithUnsupportedTPMOrCPU /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v BypassNRO /t REG_DWORD /d 1 /f;
	};
	{
		Remove-Item -LiteralPath 'Registry::HKLM\Software\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate' -Force -ErrorAction 'SilentlyContinue';
	};
	{
		Remove-Item -LiteralPath 'C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk', 'C:\Windows\System32\OneDriveSetup.exe', 'C:\Windows\SysWOW64\OneDriveSetup.exe' -ErrorAction 'Continue';
	};
	{
		Remove-Item -LiteralPath 'Registry::HKLM\Software\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate' -Force -ErrorAction 'SilentlyContinue';
	};
	{
		reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications" /v ConfigureChatAutoInstall /t REG_DWORD /d 0 /f;
	};
	{
		Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\RemovePackages.ps1' -Raw | Invoke-Expression;
	};
	{
		Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\RemoveCapabilities.ps1' -Raw | Invoke-Expression;
	};
	{
		Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\RemoveFeatures.ps1' -Raw | Invoke-Expression;
	};
	{
		net.exe accounts /maxpwage:UNLIMITED;
	};
	{
		reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f
	};
	{
		reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f;
	};
	{
		reg.exe add "HKLM\Software\Policies\Microsoft\Edge" /v HideFirstRunExperience /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f;
		reg.exe add "HKLM\Software\Policies\Microsoft\Edge\Recommended" /v StartupBoostEnabled /t REG_DWORD /d 0 /f;
	};
	{
		Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\MakeEdgeUninstallable.ps1' -Raw | Invoke-Expression;
	};
	{
		Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\SetStartPins.ps1' -Raw | Invoke-Expression;
	};
);

&amp; {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Activity 'Running scripts to customize your Windows installation. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command &#xAB;{0}&#xBB;.' -f $(
      $str = $script.ToString().Trim() -replace '\s+', ' ';
      $max = 100;
      if( $str.Length -le $max ) {
        $str;
      } else {
        $str.Substring( 0, $max - 1 ) + '&#x2026;';
      }
    );
    $start = [datetime]::Now;
    &amp; $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *&gt;&amp;1 &gt;&gt; "C:\Windows\Setup\Scripts\Specialize.log";
		</File>
		<File path="C:\Windows\Setup\Scripts\UserOnce.ps1">
$scripts = @(
	{
		Get-AppxPackage -Name 'Microsoft.Windows.Ai.Copilot.Provider' | Remove-AppxPackage;
	};
	{
		Set-WinHomeLocation -GeoId 244;
	};
	{
		$params = @{
			Path = 'Registry::HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32';
			ErrorAction = 'SilentlyContinue';
			Force = $true;
		};
		New-Item @params;
		Set-ItemProperty @params -Name '(Default)' -Value '' -Type 'String';
	};
	{
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -Type 'DWord' -Value 1;
	};
	{
		Set-ItemProperty -LiteralPath 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Type 'DWord' -Value 0;
	};
	{
		Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\SetColorTheme.ps1' -Raw | Invoke-Expression;
	};
	{
		Get-Process -Name 'explorer' -ErrorAction 'SilentlyContinue' | Where-Object -FilterScript {
			$_.SessionId -eq ( Get-Process -Id $PID ).SessionId;
		} | Stop-Process -Force;
	};
);

&amp; {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Activity 'Running scripts to configure this user account. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command &#xAB;{0}&#xBB;.' -f $(
      $str = $script.ToString().Trim() -replace '\s+', ' ';
      $max = 100;
      if( $str.Length -le $max ) {
        $str;
      } else {
        $str.Substring( 0, $max - 1 ) + '&#x2026;';
      }
    );
    $start = [datetime]::Now;
    &amp; $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *&gt;&amp;1 &gt;&gt; "$env:TEMP\UserOnce.log";
		</File>
		<File path="C:\Windows\Setup\Scripts\DefaultUser.ps1">
$scripts = @(
	{
		reg.exe add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f;
	};
	{
		Remove-ItemProperty -LiteralPath 'Registry::HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'OneDriveSetup' -Force -ErrorAction 'Continue';
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f;
	};
	{
		$params = @{
		  LiteralPath = 'Registry::HKU\DefaultUser\Control Panel\Mouse';
		  Type = 'String';
		  Value = 0;
		  Force = $true;
		};
		Set-ItemProperty @params -Name 'MouseSpeed';
		Set-ItemProperty @params -Name 'MouseThreshold1';
		Set-ItemProperty @params -Name 'MouseThreshold2';
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v TaskbarEndTask /t REG_DWORD /d 1 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\DWM" /v ColorPrevalence /t REG_DWORD /d 0 /f;
	};
	{
		reg.exe add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "UnattendedSetup" /t REG_SZ /d "powershell.exe -WindowStyle Normal -NoProfile -Command \""Get-Content -LiteralPath 'C:\Windows\Setup\Scripts\UserOnce.ps1' -Raw | Invoke-Expression;\""" /f;
	};
);

&amp; {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Activity 'Running scripts to modify the default user&#x2019;&#x2019;s registry hive. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command &#xAB;{0}&#xBB;.' -f $(
      $str = $script.ToString().Trim() -replace '\s+', ' ';
      $max = 100;
      if( $str.Length -le $max ) {
        $str;
      } else {
        $str.Substring( 0, $max - 1 ) + '&#x2026;';
      }
    );
    $start = [datetime]::Now;
    &amp; $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *&gt;&amp;1 &gt;&gt; "C:\Windows\Setup\Scripts\DefaultUser.log";
		</File>
		<File path="C:\Windows\Setup\Scripts\FirstLogon.ps1">
$scripts = @(
	{
		cmd.exe /c "rmdir C:\Windows.old";
	};
);

&amp; {
  [float] $complete = 0;
  [float] $increment = 100 / $scripts.Count;
  foreach( $script in $scripts ) {
    Write-Progress -Activity 'Running scripts to finalize your Windows installation. Do not close this window.' -PercentComplete $complete;
    '*** Will now execute command &#xAB;{0}&#xBB;.' -f $(
      $str = $script.ToString().Trim() -replace '\s+', ' ';
      $max = 100;
      if( $str.Length -le $max ) {
        $str;
      } else {
        $str.Substring( 0, $max - 1 ) + '&#x2026;';
      }
    );
    $start = [datetime]::Now;
    &amp; $script;
    '*** Finished executing command after {0:0} ms.' -f [datetime]::Now.Subtract( $start ).TotalMilliseconds;
    "`r`n" * 3;
    $complete += $increment;
  }
} *&gt;&amp;1 &gt;&gt; "C:\Windows\Setup\Scripts\FirstLogon.log";
		</File>
	</Extensions>
</unattend>
EOF
}

downloadWindowsISO() {
	# Define product IDs and names
	declare -A products=(
		["48"]="Windows 8.1 Single Language (9600.17415)"
		["2618"]="❤️ Windows 10 22H2 v1 (19045.2965)"
		["3113"]="❤️ Windows 11 24H2 (26100.1742)"
	)

	if [[ "$1" = "win81x64" ]]; then
		selected_product_id="48"
	elif [[ "$1" = "win10x64" ]]; then
		selected_product_id="2618"
	elif [[ "$1" = "win11x64" ]]; then
		selected_product_id="3113"
	fi

	# Fetch SKU information for the selected product ID
	sku_response=$(curl -s "https://api.gravesoft.dev/msdl/skuinfo?product_id=$selected_product_id")

	# Use jq to extract and format the SKU information
	selected_sku=$(echo "$sku_response" | jq -r '.Skus[] | "\(.Id) \(.Description)"' | sort | fzf --header="Select a SKU")

	# Check if a SKU was selected
	if [ -z "$selected_sku" ]; then
		echo "No SKU selected."
		exit 1
	fi

	# Extract the SKU ID from the selected SKU
	sku_id=$(echo "$selected_sku" | awk '{print $1}')

	# Fetch download options for the selected SKU
	download_response=$(curl -s "https://api.gravesoft.dev/msdl/proxy?product_id=$selected_product_id&sku_id=$sku_id")

	# Use jq to extract and format the download options
	selected_download=$(echo "$download_response" | jq -r '.ProductDownloadOptions[] | "\(.Name) \(.Uri)"' | fzf --header="Select a download option")

	# Check if a download option was selected
	if [ -z "$selected_download" ]; then
		echo "No download option selected."
		exit 1
	fi

	# Extract the download URL from the selected download option
	windowsGlobalDownloadLink=$(echo "$selected_download" | awk '{print $NF}')

	aria2c -j 16 -x 16 -s 16 -k 1M "${windowsGlobalDownloadLink}"
}

CallWindowsDownloader() {
	clear

	echo -e "Downloading $output"
	downloadWindowsISO "$1"

	iso=$(find -type f | grep "iso" | head -1 | xargs -I {} realpath "{}")
	if [[ "$1" == "win10x64" || "$1" == "win11x64" ]]; then
		mv "${iso}" "${VMS_ISO}/tmp_download-$1-$2/${output}"
	else
		mv "${iso}" "${VMS_ISO}/${output}"
	fi
}

downloadWindowsSpice() {
	echo -e "Downloading Spice Agents for copy paste functionality ..."
	aria2c -j 16 -x 16 -s 16 -k 1M "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-latest.msi"
	aria2c -j 16 -x 16 -s 16 -k 1M "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/spice-vdagent-x64-0.10.0.msi"
	aria2c -j 16 -x 16 -s 16 -k 1M "https://www.spice-space.org/download/windows/usbdk/UsbDk_1.0.22_x64.msi"
}

winget() {
	# CACHE PASSWORD
	sudo sed -i '71 a Defaults        timestamp_timeout=30000' /etc/sudoers

	mkdir -p "$VMS_ISO"

	if [[ "$1" == "win81x64" ]]; then

		cd "${VMS_ISO}"

		# Download vanilla windows iso

		CallWindowsDownloader "$1"

		# Download spice setup files

		mkdir "windows-spice-setupfiles"
		cd "windows-spice-setupfiles"
		downloadWindowsSpice
		cd ..

	else

		read -p "Do you want an unattendeded installer ? (y/n/yes/no):" want_unattended
		username=""
		if [[ "${want_unattended}" = "y" || "${want_unattended}" = "yes" ]]; then
			read -p "Enter username for your account:" username
		fi

		epoch_date_created=$(date +%s)

		mkdir -p "${VMS_ISO}/tmp_download-$1-${epoch_date_created}"
		cd "${VMS_ISO}/tmp_download-$1-${epoch_date_created}"

		# Download vanilla windows iso

		CallWindowsDownloader "$1" "$epoch_date_created"

		# Create iso with unattended.xml

		mkdir mnt
		sudo mount -o rw,loop "${output}" mnt

		epoch=$(date +%s)
		mkdir "win-${epoch}"
		echo "Doing magic please wait ..."
		sudo cp -r mnt/* "win-${epoch}"

		mkdir "modifications-${epoch}"
		cd "modifications-${epoch}"

		if [[ "${want_unattended}" = "y" || "${want_unattended}" = "yes" ]]; then
			clear
			echo "Creating unattended installer ...."
			downloadWindowsSpice
			unattended_windows "${VMS_ISO}/tmp_download-$1-${epoch_date_created}/modifications-${epoch}/autounattend.xml"
			sed -i "s/<USERNAME_HERE>/${username}/g" "${VMS_ISO}/tmp_download-$1-${epoch_date_created}/modifications-${epoch}/autounattend.xml"
			sed -i "s/ Project//g" "${VMS_ISO}/tmp_download-$1-${epoch_date_created}/modifications-${epoch}/autounattend.xml"
		else
			echo "Creating non-unattended installer ...."
		fi

		cd ..

		sudo umount mnt
		sudo rm -rf mnt

		cd "${VMS_ISO}/tmp_download-$1-${epoch_date_created}"

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
			-o "../${output}" \
			"./win-${epoch}" "./modifications-${epoch}"

		if [[ "${want_unattended}" = "y" || "${want_unattended}" = "yes" ]]; then
			fileName=$(basename "${output}" ".iso")
			suffix="unattended"

			if [[ "${windowsGlobalDownloadLink}" != "" ]]; then
				mv "../${output}" "../${fileName}-${suffix}-${epoch}.iso"
			else
				mv "../${output}" "../${fileName}-${suffix}-${epoch}.iso"
			fi

		else
			fileName=$(basename "${output}" ".iso")
			suffix="non-unattended"

			if [[ "${windowsGlobalDownloadLink}" != "" ]]; then
				mv "../${output}" "../${fileName}-${suffix}-${epoch}.iso"
			else
				mv "../${output}" "../${fileName}-${suffix}-${epoch}.iso"
			fi

		fi
	fi

	cd "${VMS_ISO}"
	rm -rf "virtio.iso"
	clear

	# DELETE CACHED PASSWORD
	sudo sed -i '72d' /etc/sudoers

	# Download virtio drivers iso
	echo "Downloading Virtio Drivers for setting higher resolution ..."
	aria2c -j 16 -x 16 -s 16 -k 1M "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso" -o "virtio.iso"

	if [[ "${windowsGlobalDownloadLink}" != "" ]]; then
		sudo rm -rf "${VMS_ISO}/tmp_download-$1-${epoch_date_created}"
	fi
}

win8_1url() {
	output="Windows8_1.iso"
	winget "win81x64"
}

win10url() {
	output="Windows10.iso"
	winget "win10x64"
}

win11url() {
	output="Windows11.iso"
	winget "win11x64"
}

## Bootable USB

ventoyurl() {
	mirror="https://github.com/ventoy/Ventoy"
	ver=$(curl "${mirror}" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | cut -d"/" -f6 | xargs | tr -d "v")
	wget "${mirror}/releases/download/v$ver/ventoy-$ver-linux.tar.gz" -O "$VMS_ISO/ventoy.tar.gz"
}

balena_etcher_url() {
	mirror="https://github.com/balena-io/etcher/"
	ver=$(curl "${mirror}" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep -i "releases/tag" | cut -d"/" -f6 | xargs | tr -d "v")
	wget "${mirror}/releases/download/v$ver/balenaEtcher-${ver}-x64.AppImage" -O "$VMS_ISO/balena_etcher.AppImage"
}

## Recovery Environment

hirens_bootcd_pe_url() {
	cd "${VMS_ISO}"
	aria2c -j 16 -x 16 -s 16 -k 1M "https://www.hirensbootcd.org/files/HBCD_PE_x64.iso"
	cd
}

medicat_url() {
	mirror="https://medicatusb.com/"
	cd "${VMS_ISO}"
	link=$(curl -s "${mirror}" | grep -o '<a .*href=.*>' | sed -e 's/<a /\n<a /g' | sed -e 's/<a .*href=['"'"'"]//' -e 's/["'"'"'].*$//' -e '/^$/ d' | grep dog | awk -F"=" '{print $2}' | cut -d" " -f1 | xargs)
	aria2c -j 16 -x 16 -s 16 -k 1M "${link}"
	cd
}

# Categories
arch=(archlinux archlinuxgui manjaro arcolinux archbang parabola endeavour artix arco garuda rebornos namib obarun archcraft peux bluestar xerolinux cachyos)
deb=(debian ubuntu linuxmint zorinos popos deepin mxlinux knoppix kali puppy pureos elementary backbox devuan jingos cutefishos parrot antix trisquel peppermintos nitrux damn_small_linux vanillaos tails_os)
rpm=(fedora centos opensuse rosa altlinux mandriva mageia clearos alma rocky qubes nobara ultramarine springdale berry risios eurolinux)
other=(alpine tinycore porteus slitaz pclinuxos void fourmlinux kaos clearlinux dragora slackware adelie plop solus peropesis openmamba pisi)
sourcebased=(gentoo calculate nixos guix crux gobolinux easyos)
containers=(rancheros k3os flatcar silverblue photon coreos dcos)
bsd=(freebsd netbsd openbsd ghostbsd hellosystem dragonflybsd pfsense opnsense midnightbsd truenas nomadbsd hardenedbsd xigmanas clonos)
notlinux=(openindiana minix haiku menuetos kolibri reactos freedos)
windows=(windows8_1 windows10 windows11)
bootable_usb=(ventoy balena_etcher)
recovery_environment=(hirens_bootcd_pe medicat)

# All distributions
category_names=("Arch-based" "DEB-based" "RPM-based" "Other" "Source-based" "Containers and DCs" "BSD, NAS, Firewall" "Not linux" "Windows" "Bootable_USB" "Recovery Environment")
distro_all=("arch" "deb" "rpm" "other" "sourcebased" "containers" "bsd" "notlinux" "windows" "bootable_usb" "recovery_environment")
distro_arr=("${arch[@]}" "${deb[@]}" "${rpm[@]}" "${other[@]}" "${sourcebased[@]}" "${containers[@]}" "${bsd[@]}" "${notlinux[@]}" "${windows[@]}" "${bootable_usb[@]}" "${recovery_environment[@]}")

# Legend ## Distroname ## Arch  ## Type     ## Download URL function name

# Archlinux-based distros
archlinux=("ArchLinux" "amd64" "rolling" "archurl")
archlinuxgui=("ArchLinuxGUI" "amd64" "rolling" "archguiurl")
manjaro=("Manjaro" "amd64" "rolling" "manjarourl")
arcolinux=("Arcolinux" "amd64" "rolling" "arcourl")
archbang=("Archbang" "amd64" "rolling" "archbangurl")
parabola=("Parabola" "amd64" "rolling" "parabolaurl")
endeavour=("EendeavourOS" "amd64" "latest" "endeavoururl")
artix=("ArtixLinux" "amd64" "daily" "artixurl")
arco=("ArcoLinux" "amd64" "release" "arcourl")
garuda=("Garuda" "amd64" "release" "garudaurl")
rebornos=("RebornOS" "amd64" "release" "rebornurl")
namib=("Namib" "amd64" "release" "namiburl")
obarun=("Obarun" "amd64" "rolling" "obarunurl")
archcraft=("ArchCraft" "amd64" "release" "archcrafturl")
peux=("Peux" "amd64" "release" "peuxurl")
bluestar=("Bluestar" "amd64" "release" "bluestarurl")
xerolinux=("XeroLinux" "amd64" "rolling" "xerourl")
cachyos=("CachyOS" "amd64" "latest" "cachyosurl")

# Consider in the future if the distros continue to evolve
# https://sourceforge.net/projects/calinixos/
# https://sourceforge.net/projects/hefftorlinux/

# Debian/Ubuntu-based distros
debian=("Debian" "amd64" "testing" "debianurl")
ubuntu=("Ubuntu" "amd64" "daily-live" "ubuntuurl")
linuxmint=("LinuxMint" "amd64" "release" "minturl")
zorinos=("ZorinOS" "amd64" "core" "zorinurl")
popos=("PopOS" "amd64" "release" "popurl")
deepin=("Deepin" "amd64" "release" "deepinurl")
mxlinux=("MXLinux" "amd64" "release" "mxurl")
knoppix=("Knoppix" "amd64" "release" "knoppixurl")
kali=("Kali" "amd64" "kali-weekly" "kaliurl")
puppy=("Puppy" "amd64" "bionicpup64" "puppyurl")
pureos=("PureOS" "amd64" "release" "pureurl")
elementary=("ElementaryOS" "amd64" "release" "elementurl")
backbox=("Backbox" "amd64" "release" "backboxurl")
devuan=("Devuan" "amd64" "beowulf" "devuanurl")
jingos=("JingOS" "amd64" "v0.9" "jingosurl")
cutefishos=("CutefishOS" "amd64" "release" "cutefishosurl")
parrot=("Parrot" "amd64" "testing" "parroturl")
antix=("Antix" "amd64" "full" "antixurl")
trisquel=("Trisquel" "amd64" "latest" "trisquelurl")
peppermintos=("Peppermintos" "amd64" "latest" "peppermintosurl")
nitrux=("nitrux" "amd64" "latest" "nitruxurl")
damn_small_linux=("damn_small_linux" "amd64" "latest" "damn_small_linux_url")
vanillaos=("vanillaos" "amd64" "latest" "vanillaos_url")
tails_os=("tails_os" "amd64" "latest" "tailsurl")

# Add if wanted
# https://distrowatch.com/table.php?distribution=rebeccablackos
# https://distrowatch.com/table.php?distribution=regata
# https://distrowatch.com/table.php?distribution=uruk
# https://distrowatch.com/table.php?distribution=netrunner

# Fedora/RedHat-based distros
fedora=("Fedora" "amd64" "Workstation" "fedoraurl")
centos=("CentOS" "amd64" "stream" "centosurl")
opensuse=("OpenSUSE" "amd64" "tumbleweed" "suseurl")
rosa=("ROSA" "amd64" "desktop-fresh" "rosaurl")
altlinux=("ALTLinux" "amd64" "release" "alturl")
mandriva=("Mandriva" "amd64" "release" "mandrivaurl")
mageia=("Mageia" "amd64" "cauldron" "mageiaurl")
clearos=("ClearOS" "amd64" "release" "clearosurl")
alma=("AlmaLinux" "amd64" "release" "almaurl")
rocky=("RockyLinux" "amd64" "rc" "rockyurl")
qubes=("QubesOS" "amd64" "release" "qubesurl")
nobara=("Nobara" "amd64" "release" "nobaraurl")
ultramarine=("Ultramarine" "amd64" "release" "ultraurl")
springdale=("Springdale" "amd64" "release" "springurl")
berry=("Berry" "amd64" "release" "berryurl")
risios=("RisiOS" "amd64" "release" "risiurl")
eurolinux=("EuroLinux" "amd64" "release" "eurourl")

# Other distros
alpine=("Alpine" "amd64" "extended" "alpineurl")
tinycore=("TinyCore" "amd64" "current" "tinycoreurl")
porteus=("Porteus" "amd64" "kiosk" "porteusurl")
slitaz=("SliTaz" "amd64" "rolling" "slitazurl")
pclinuxos=("PCLinuxOS" "amd64" "livecd" "pclinuxosurl")
void=("Void" "amd64" "live" "voidurl")
fourmlinux=("4mlinux" "amd64" "release" "fourmurl")
kaos=("kaos" "amd64" "release" "kaosurl")
clearlinux=("ClearLinux" "amd64" "release" "clearurl")
dragora=("Dragora" "amd64" "release" "dragoraurl")
slackware=("Slackware" "amd64" "current" "slackwareurl")
adelie=("Adelie" "amd64" "rc1" "adelieurl")
plop=("Plop" "amd64" "current-stable" "plopurl")
solus=("Solus" "amd64" "release" "solusurl")
peropesis=("Peropesis" "amd64" "live" "peropesisurl")
openmamba=("Openmamba" "amd64" "rolling" "openmambaurl")
pisi=("Pisilinux" "amd64" "release" "pisiurl")

# Source-based distros
gentoo=("Gentoo" "amd64" "admincd" "gentoourl")
calculate=("Calculate" "amd64" "release" "calcurl")
nixos=("NixOS" "amd64" "unstable" "nixurl")
guix=("Guix" "amd64" "release" "guixurl")
crux=("CRUX" "amd64" "release" "cruxurl")
gobolinux=("GoboLinux" "amd64" "release" "gobourl")
easyos=("EasyOS" "amd64" "dunfell" "easyurl")

# Distros for containers and data-centers
rancheros=("RancherOS" "amd64" "release" "rancherurl")
k3os=("K3OS" "amd64" "release" "k3osurl")
flatcar=("Flatcar" "amd64" "release" "flatcarurl")
silverblue=("Silverblue" "amd64" "release" "silverblueurl")
photon=("PhotonOS" "amd64" "fulliso" "photonurl")
coreos=("CoreOS" "amd64" "next" "coreosurl")
dcos=("DC/OS" "amd64" "script" "dcosurl")

# FreeBSD family
freebsd=("FreeBSD" "amd64" "release" "freebsdurl")
netbsd=("NetBSD" "amd64" "release" "netbsdurl")
openbsd=("OpenBSD" "amd64" "release" "openbsdurl")
ghostbsd=("GhostBSD" "amd64" "release" "ghostbsdurl")
hellosystem=("HelloSystem" "amd64" "v0.5" "hellosystemurl")
dragonflybsd=("DragonflyBSD" "amd64" "release" "dragonurl")
pfsense=("pfSense" "amd64" "release" "pfsenseurl")
opnsense=("opnsense" "amd64" "release" "opnsenseurl")
midnightbsd=("midnightbsd" "amd64" "release" "midnightbsdurl")
truenas=("truenas" "amd64" "release" "truenasurl")
nomadbsd=("nomadbsd" "amd64" "release" "nomadbsdurl")
hardenedbsd=("hardenedbsd" "amd64" "latest" "hardenedbsdurl")
xigmanas=("xigmanas" "amd64" "release" "xigmanasurl")
clonos=("clonos" "amd64" "release" "clonosurl")

# Add more FreeBSD stuff
# https://en.wikipedia.org/wiki/List_of_BSD_operating_systems
# https://en.wikipedia.org/wiki/List_of_products_based_on_FreeBSD

# Not linux, but free

# Add More Solaris stuff https://solaris.com

openindiana=("OpenIndiana" "amd64" "release" "indianaurl")
minix=("MINIX" "amd64" "release" "minixurl")
haiku=("Haiku" "amd64" "nightly" "haikuurl")
menuetos=("MenuetOS" "amd64" "release" "menueturl")
kolibri=("Kolibri" "amd64" "release" "kolibriurl")
reactos=("ReactOS" "amd64" "release" "reactosurl")
freedos=("FreeDOS" "amd64" "release" "freedosurl")

# Windows
windows8_1=("Windows8_1" "amd64" "latest" "win8_1url")
windows10=("Windows10" "amd64" "latest" "win10url")
windows11=("Windows11" "amd64" "latest" "win11url")

# Bootable USB
ventoy=("ventoy" "amd64" "latest" "ventoyurl")
balena_etcher=("balena_etcher" "amd64" "latest" "balena_etcher_url")

# Recovery Environment
hirens_bootcd_pe=("hirens_bootcd_pe" "amd64" "latest" "hirens_bootcd_pe_url")
medicat=("medicat" "amd64" "latest" "medicat_url")

drawmenu() {
	q=0

	for ((i = 0; i < ${#distro_all[@]}; i++)); do
		col+="${category_names[$i]}: \n"
		dist=${distro_all[$i]}
		typeset -n arr=$dist
		for ((d = 0; d < ${#arr[@]}; d++)); do
			allDistros+="$q.${arr[$d]}.[${dist}]\n"
			((q++))
		done
	done
}

normalmode() {
	mkdir -p "${VMS_ISO}"
	echo -e "\n\n"
	allDistros=$(echo "$allDistros" | sed '/^\s*$/d')
	drawmenu
	x=$(echo -e "$allDistros" | sed '/^$/d' | fzf --cycle -m --prompt "Please choose distro to download:" --height 15 | awk -F "." '{print $1}' | xargs)

	# Happens if the input is empty
	if [ -z "$x" ]; then
		echo "Empty distribution number.Exiting"
		exit
	fi # "Empty" handling

	# Happens if we ask only for menu
	if [ "$x" = "menu" ]; then
		drawmenu
		exit
	fi

	# This questions are asked ONLY if user hadn't used the option "all".
	if [ "$x" != "all" ] && [ "$x" != "filesize" ] && [ "$x" != "netbootxyz" ] && [ "$x" != "netbootsal" ] && [ "$noconfirm" != "1" ] && [ "$x" != "netbootipxe" ]; then
		for distr in $x; do
			dist=${distro_arr[$distr]}
			typeset -n arr=$dist
			echo "You choose ${arr[0]} distro ${arr[2]}, built for ${arr[1]} arch."
			$"${arr[3]}"
		done
	else

		if [ "$noconfirm" = "1" ]; then
			for distr in $x; do
				dist=${distro_arr[$distr]}
				typeset -n arr=$dist
				$"${arr[3]}"
			done
			#done
		fi

		# Sizecheck handling: show the distribution file sizes
		if [ "$x" = "filesize" ]; then
			for ((i = 0; i < ${#distro_arr[@]}; i++)); do xx+="$i "; done
			x=$xx
			#for ((i=0; i<${#distro_arr[@]}; i++)); do
			for distr in $x; do
				dist=${distro_arr[$distr]}
				typeset -n arr=$dist
				$"${arr[3]}" "filesize"
			done
			#done
		fi

		if [ "$x" = "netbootxyz" ]; then
			echo "Downloading netboot image from netboot.xyz, please wait..." && netbootxyz
			echo "Loading netboot.xyz.iso..." && $cmd -boot d -cdrom netboot.xyz.iso -m $ram
		fi

		if [ "$x" = "netbootsal" ]; then
			echo "Downloading netboot image from boot.salstar.sk, please wait..." && netbootsal
			echo "Loading ipxe.iso..." && $cmd -boot d -cdrom ipxe.iso -m $ram
		fi

		if [ "$x" = "netbootipxe" ]; then
			echo "Downloading netboot image from boot.ipxe.org, please wait..." && netbootipxe
			echo "Loading bootipxe.iso..." && $cmd -boot d -cdrom bootipxe.iso -m $ram
		fi
	fi
}

if [ "$silent" != "1" ]; then
	helpsection
fi

normalmode
