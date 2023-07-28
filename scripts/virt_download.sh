#!/bin/bash

helpsection() {
	echo "/----------------------------------------------------------------------------------------------------------------------------------------\ "
	echo "| Script downloads recent (latest release) linux ISOs and spins a VM for a test. This is kinda distrohopper dream machine.               | "
	echo "| It consist of the file with distro download functions (distrofunctions.sh) as well as this script (download.sh).                       | "
	echo "| Theoretically, the script should always download recent linux ISOs without any updates. But, if the developer(s)                       | "
	echo "| change the download URL or something else, it might be required to do manual changes - probably in distrofunctions.sh.                 | "
	echo "| Requirements: linux, bash, curl, wget, awk, grep, xargs, pr (these tools usually are preinstalled on linux)                            | "
	echo "| Some distros are shared as archive. So you'll need xz for guix, bzip2 for minix, zip for haiku & reactos, and, finally 7z for kolibri. | "
	echo "| Written by SecurityXIII / Aug 2020 ~ Jan 2023 / Kopimi un-license /--------------------------------------------------------------------/ "
	echo "\-------------------------------------------------------------------/"
	echo "+ How to use?"
	echo " If you manually pick distros (opt. one or two) you will be prompted about launching a VM for test spin for each distro."
	echo " Multiple values are also supported. Please choose one out of five options:"
	echo "* one distribution (e.g. type 0 for archlinux)*"
	echo "* several distros - space separated (e.g. for getting both Arch and Debian, type '0 4' (without quotes))*"
	echo "* 'all' option, the script will ONLY download ALL of the ISOs (warning: this can take a lot of space (100+GB) !)"
	echo "* 'filesize' option will check the local (downloaded) filesizes of ISOs vs. the current/recent ISOs filesizes on the websites"
	echo "* 'netbootxyz' option allows you to boot from netboot.xyz via network"
	echo "* 'netbootsal' option will boot from boot.salstar.sk"
}

# the public ipxe mirror does not work
#echo "* 'netbootipxe' option will boot from boot.ipxe.org"

# NB: I wanted to add ElementaryOS but the developers made it way too hard to implement auto-downloading.
# If you can find constant mirror or place for actual release of ElementaryOS, please do a pull-request or just leave a comment.

#### Constant Variables
allDistros="all\n"

# Download functions and commands

wgetcmd() {
	mkdir -p "$HOME/Downloads/VM_ISO"
	cd $HOME/Downloads/VM_ISO
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
		wgetcmd
	fi
}

# Update latest distro URL functions

archurl() {
	mirror="https://archlinux.org/download/"
	x=$(curl -s $mirror | grep -m1 geo | awk -F"\"" '{ print $2 }')
	y=$(curl -s $x | grep -m1 archlinux | awk -F".iso" '{ print $1 }' | awk -F"\"" '{ print $2 }')
	new="$x/$y.iso"
	output="archlinux.iso"
	checkfile $1
}

manjarourl() {
	mirror="https://manjaro.org/download/"
	x=$(curl -s $mirror | grep btn-fi | grep xfce | awk -F"\"" '{ print $4 }')
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
	x=$(curl -s $mirror | grep mate-openrc | head -1 | awk -F\" '{ print $2 }')
	new="$mirror/$x"
	output="artix.iso"
	checkfile $1
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

archlabsurl() {
	mirror="https://sourceforge.net/projects/archlabs-linux-minimo/files/latest/download"
	new="$mirror"
	output="archlabs.iso"
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
	#mirror="https://fosstorrents.com/files/pop-os_22.04_amd64_intel_20.iso-hybrid.torrent"
	mirrorone="https://fosstorrents.com/distributions/pop-os/"
	x=$(curl -s $mirrorone | html2text | grep -m1 ".torrent)" | awk -F"(" '{ print $2 }' | awk -F")" '{ print $1 }')
	mirror="https://fosstorrents.com"
	new="$mirror$x"
	echo "Warning! This torrent is from fosstorrents, so unofficial. And to download (aria2c) you need to install aria2."
	ariacmd
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
	new="$one"
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
	x=$(curl -s $mirror | grep "home" | grep -m1 amd64.iso | awk -F"\"" '{ print $4 }')
	new="$mirror$x"
	output="parrot.iso"
	checkfile $1
}

fedoraurl() {
	mirror="https://getfedora.org/en/workstation/download/"
	new=$(curl -s $mirror | html2text | grep -m2 iso | awk -F "(" 'NR%2{printf "%s",$0;next;}1' | awk -F"(" '{ print $2 }' | awk -F")" '{ print $1 }')
	# Legacy
	#mirror="https://www.happyassassin.net/nightlies.html"
	#x=$(curl -s $mirror | grep -m1 Fedora-Workstation-Live-x86_64-Rawhide | awk -F\" '{ print $4 }')
	#new="$x"
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
	new=$(curl -s $mirror | html2text | grep -m1 DVD | awk -F'(' '{ print $2 }' | awk -F')' '{ print $1 }')
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
	mirror="https://risi.io/downloads"
	new=$(curl -s $mirror | grep Download | grep -m1 .iso | awk -F"\"" '{ print $2 }')
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
	x=$(curl -s $mirror | grep "xfce" | grep -m1 "x86_64" | awk -F">" '{ print $2 }' | awk -F"<" '{ print $1 }')
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
	mirror="https://clearlinux.org/downloads"
	x=$(curl -s $mirror | grep live | grep -m1 iso | awk -F\" '{ print $2 }')
	new="$x"
	output="clearlinux.iso"
	checkfile $1
}

dragoraurl() {
	mirror="http://rsync.dragora.org/current/iso/beta/"
	echo "Unfortunately, current Dragora mirror ($mirror) is unavailable"
	#x=$(curl -s $mirror | grep -m1 x86_64 | awk -F\' '{ print $2 }')
	#new="$mirror$x"
	#output="dragora.iso"
	#checkfile $1
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
	echo "Unfortunately, current Solus mirror ($mirror) is unavailable"
	#x=$(curl -s $mirror | grep -m1 iso | awk -F\" '{ print $2 }')
	#new="$x"
	#output="solus.iso"
	#checkfile $1
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

sabayonurl() {
	mirror="https://www.sabayon.org/desktop/"
	echo "Unfortunately, current Sabayon mirror ($mirror) is unavailable"
	#x=$(curl -s $mirror | grep GNOME.iso | head -1 | awk -F"http://" '{ print $2 }' | awk -F\" '{ print $1 }')
	#new="http://$x"
	#output="sabayon.iso"
	#checkfile $1
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
	mirror="https://www.openbsd.org/faq/faq4.html"
	new=$(curl -s $mirror | grep -m1 -e 'iso.*amd64' | awk -F\" '{ print $2 }')
	output="openbsd.iso"
	notlinux
	checkfile $1
}

ghostbsdurl() {
	mirror="http://download.fr.ghostbsd.org/development/amd64/latest/"
	x=$(curl -s -L $mirror | grep ".iso<" | tail -1 | awk -F\" '{ print $2 }')
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
		[ ! -f $output ] && wgetcmd && echo "Please wait, unpacking pfSense..." && gzip -d $output || echo "pfSense already downloaded."
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
		[ ! -f $output ] && wgetcmd && echo "Please wait, unpacking opnsense..." && bzip2 -k -d $output && rm $output || echo "OpnSense already downloaded."
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
		[[ ! -f $output && ! -f "nomadbsd.img" ]] && wgetcmd && echo "Please wait, unpacking NomadBSD..." && lzma -d $output || echo "NomadBSD already downloaded."
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
		[ ! -f $output ] && wgetcmd && echo "Please wait, unpacking minix..." && bzip2 -k -d $output || echo "Minix already downloaded."
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
		[ ! -f $output ] && wgetcmd && echo "Please wait, unzipping haiku..." && unzip $output && rm ReadMe.md && mv haiku*iso haiku.iso || echo "Haiku already downloaded."
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
		[ ! -f $output ] && wgetcmd && echo "Wait, unzipping menuetos..." && unzip $output && mv M64*.IMG menuetos.img || echo "Menuet already downloaded."
	fi
}

kolibriurl() {
	new="https://builds.kolibrios.org/eng/latest-iso.7z"
	output="kolibrios.7z"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[[ ! -f $output && ! -f "kolibri.iso" ]] && wgetcmd && echo "Un7zipping kolibri..." && 7z x $output && sleep 7 && rm $output && rm "INSTALL.TXT" || echo "Kolibri already downloaded."
	fi
}

reactosurl() {
	new="https://sourceforge.net/projects/reactos/files/latest/download"
	output="reactos.zip"
	if [ "$1" == "filesize" ]; then
		notlinux
		getsize
	else
		[[ ! -f $output && ! -f "reactos.iso" ]] && wgetcmd && echo "Please wait, unzipping reactos..." && unzip $output && mv React*iso reactos.iso || echo "ReactOS already downloaded."
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
		[[ ! -f $output && ! -f "freedos.img" ]] && wgetcmd && echo "Please wait, unzipping FreeDOS..." && unzip $output && sleep 10 && rm $output && rm readme.txt && mv FD13BOOT.img freedos.img && mv FD13LIVE.iso freedos.iso || echo "FreeDOS already downloaded."
	fi
}

unattended_windows() {
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
        <Manufacturer>qemu&KVM Project</Manufacturer>
        <Model>qemu&KVM</Model>
        <SupportHours>24/7</SupportHours>
        <SupportPhone></SupportPhone>
        <SupportProvider>qemu&KVM Project</SupportProvider>
        <SupportURL>https://www.qemu.org</SupportURL>
      </OEMInformation>
      <OEMName>qemu&KVM Project</OEMName>
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
        <FullName>qemu&KVM</FullName>
        <Organization>qemu&KVM Project</Organization>
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
          <Value>qemu&KVM</Value>
          <PlainText>true</PlainText>
        </Password>
        <Enabled>true</Enabled>
        <Username>qemu&KVM</Username>
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
              <Value>qemu&KVM</Value>
              <PlainText>true</PlainText>
            </Password>
            <Description>qemu&KVM</Description>
            <DisplayName>qemu&KVM</DisplayName>
            <Group>Administrators</Group>
            <Name>qemu&KVM</Name>
          </LocalAccount>
        </LocalAccounts>
      </UserAccounts>
      <RegisteredOrganization>qemu&KVM Project</RegisteredOrganization>
      <RegisteredOwner>qemu&KVM</RegisteredOwner>
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

callMido() {
	clear
	echo -e "Downloading $output"
	wget "https://raw.githubusercontent.com/ElliotKillick/Mido/main/Mido.sh" -O mido
	chmod +x mido
	./mido "$1"
	iso=$(find -type f | grep "iso" | head -1 | xargs -I {} realpath "{}")
	if [[ "$1" == "win10x64" || "$1" == "win11x64" ]]; then
		mv "${iso}" "${VM_PATH}/unattended/${output}"
	fi
	rm -rf mido
}

winget() {
	# CACHE PASSWORD
	sudo sed -i '71 a Defaults        timestamp_timeout=30000' /etc/sudoers

	VM_PATH="$HOME/Downloads/VM_ISO"
	mkdir -p "$VM_PATH"

	if [[ "$1" == "win7x64-ultimate" || "$1" == "win81x64" ]]; then
		cd "${VM_PATH}"
		callMido "$1"
	else
		sudo rm -rf "${VM_PATH}/unattended"
		mkdir -p "${VM_PATH}/unattended"
		cd "${VM_PATH}/unattended"

		callMido "$1"

		mkdir mnt
		sudo mount -o loop "${output}" mnt

		epoch=$(date +%s)
		mkdir "win-${epoch}"
		sudo cp -r mnt/* "win-${epoch}"

		mkdir "modifications-${epoch}"
		cd "modifications-${epoch}"
		clear
		echo -e "Downloading Spice Agents for copy paste functionality ..."
		aria2c -j 16 -x 16 -s 16 -k 1M "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-latest.msi"
		aria2c -j 16 -x 16 -s 16 -k 1M "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/spice-vdagent-x64-0.10.0.msi"
		aria2c -j 16 -x 16 -s 16 -k 1M "https://www.spice-space.org/download/windows/usbdk/UsbDk_1.0.22_x64.msi"
		unattended_windows "${VM_PATH}/unattended/modifications-${epoch}/autounattend.xml"
		cd ..

		sudo umount mnt
		sudo rm -rf mnt

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
			"win-${epoch}" "modifications-${epoch}"
	fi

	# DELETE CACHED PASSWORD
	sudo sed -i '72d' /etc/sudoers

	cd "${VM_PATH}"
	rm -rf "virtio.iso"
	clear
	echo -e "Downloading Spice Agents for copy paste functionality ..."

	echo "Downloading Virtio Drivers for setting higher resolution ..."
	aria2c -j 16 -x 16 -s 16 -k 1M "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso" -o "virtio.iso"
}

win7url() {
	output="Windows7_Ultimate.iso"
	winget "win7x64-ultimate"
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

# Categories
arch=(archlinux manjaro arcolinux archbang parabola endeavour artix arco garuda rebornos archlabs namib obarun archcraft peux bluestar xerolinux)
deb=(debian ubuntu linuxmint zorinos popos deepin mxlinux knoppix kali puppy pureos elementary backbox devuan jingos cutefishos parrot)
rpm=(fedora centos opensuse rosa altlinux mandriva mageia clearos alma rocky qubes nobara ultramarine springdale berry risios eurolinux)
other=(alpine tinycore porteus slitaz pclinuxos void fourmlinux kaos clearlinux dragora slackware adelie plop solus peropesis openmamba pisi)
sourcebased=(gentoo sabayon calculate nixos guix crux gobolinux easyos)
containers=(rancheros k3os flatcar silverblue photon coreos dcos)
bsd=(freebsd netbsd openbsd ghostbsd hellosystem dragonflybsd pfsense opnsense midnightbsd truenas nomadbsd hardenedbsd xigmanas clonos)
notlinux=(openindiana minix haiku menuetos kolibri reactos freedos windows7 windows8_1 windows10 windows11)

# All distributions
category_names=("Arch-based" "DEB-based" "RPM-based" "Other" "Source-based" "Containers and DCs" "BSD, NAS, Firewall" "Not linux")
distro_all=("arch" "deb" "rpm" "other" "sourcebased" "containers" "bsd" "notlinux")
distro_arr=("${arch[@]}" "${deb[@]}" "${rpm[@]}" "${other[@]}" "${sourcebased[@]}" "${containers[@]}" "${bsd[@]}" "${notlinux[@]}")

# Legend ## Distroname ## Arch  ## Type     ## Download URL function name

# Archlinux-based distros
archlinux=("ArchLinux" "amd64" "rolling" "archurl")
manjaro=("Manjaro" "amd64" "rolling" "manjarourl")
arcolinux=("Arcolinux" "amd64" "rolling" "arcourl")
archbang=("Archbang" "amd64" "rolling" "archbangurl")
parabola=("Parabola" "amd64" "rolling" "parabolaurl")
endeavour=("EendeavourOS" "amd64" "latest" "endeavoururl")
artix=("ArtixLinux" "amd64" "daily" "artixurl")
arco=("ArcoLinux" "amd64" "release" "arcourl")
garuda=("Garuda" "amd64" "release" "garudaurl")
rebornos=("RebornOS" "amd64" "release" "rebornurl")
archlabs=("ArchLabs" "amd64" "release" "archlabsurl")
namib=("Namib" "amd64" "release" "namiburl")
obarun=("Obarun" "amd64" "rolling" "obarunurl")
archcraft=("ArchCraft" "amd64" "release" "archcrafturl")
peux=("Peux" "amd64" "release" "peuxurl")
bluestar=("Bluestar" "amd64" "release" "bluestarurl")
xerolinux=("XeroLinux" "amd64" "rolling" "xerourl")

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
sabayon=("Sabayon" "amd64" "daily" "sabayonurl")
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
windows7=("Windows7_Ultimate" "amd64" "latest" "win7url")
windows8_1=("Windows8_1" "amd64" "latest" "win8_1url")
windows10=("Windows10" "amd64" "latest" "win10url")
windows11=("Windows11" "amd64" "latest" "win11url")

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
	echo -e "\n\n\n"
	allDistros=$(echo "$allDistros" | sed '/^\s*$/d')
	drawmenu
	x=$(echo -e "$allDistros" | fzf --prompt "Please choose distro to download:" --height 15 | awk -F "." '{print $1}' | xargs)

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

			echo "You choose ${arr[0]} distro ${arr[2]}, built for ${arr[1]} arch. Do you want to download ${arr[0]} ISO? (y / n)"
			read z
			if [ $z = "y" ]; then $"${arr[3]}"; fi
		done
	else

		# All handling: automatic download will happen if user picked "all" option, no questions asked.
		if [ "$x" = "all" ]; then
			for ((i = 0; i < ${#distro_arr[@]}; i++)); do xx+="$i "; done
			x=$xx
			#for ((i=0; i<${#distro_arr[@]}; i++)); do
			for distr in $x; do
				dist=${distro_arr[$distr]}
				typeset -n arr=$dist
				$"${arr[3]}"
			done
			#done
		fi

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

quickmode() {
	IFS=,
	for distr in $distros; do
		dist=${distro_arr[$distr]}
		typeset -n arr=$dist
		$"${arr[3]}"
	done
	exit 0
}

VALID_ARGS=$(getopt -o hysd: --long help,noconfirm,silent,distro: -- "$@")
if [[ $? -ne 0 ]]; then
	exit 1
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
	case "$1" in
	-h | --help)
		helpsection
		echo "Valid command line flags:"
		echo "-h/--help: Show this help"
		echo "-y/--noconfirm: Download specified distro without confirmation. "
		echo "-s/--silent: Don't show help or extra info."
		echo "-d/--distro: Download distributions specified in the comma-separated list. Example: 0,2,34"
		exit 0
		;;
	-y | --noconfirm)
		echo "-y/--noconfirm option specified. Script will download specified distro without confirmation."
		noconfirm=1
		shift
		;;
	-s | --silent)
		echo "-s/--silent option specified. Script will not show help or extra info."
		silent=1
		shift
		;;
	-d | --distro)
		echo "-d/--distro option specified. Script will download distributions with the following numbers: '$2'"
		distros="$2"
		quickmode
		;;
	--)
		shift
		break
		;;
	esac
done

if [ "$silent" != "1" ]; then helpsection; fi

normalmode
