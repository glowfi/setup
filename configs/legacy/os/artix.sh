#!/usr/bin/env bash

# CACHE PASSWORD

sudo sed -i '71 a Defaults        timestamp_timeout=30000' /etc/sudoers

# Synchronize

sudo pacman -Syy

# Enable archlinux

sudo pacman -S --noconfirm artix-archlinux-support
sudo tee -a /etc/pacman.conf <<EOF

[extra]
Include = /etc/pacman.d/mirrorlist-arch

[community]
Include = /etc/pacman.d/mirrorlist-arch
EOF
sudo pacman-key --populate archlinux
sudo pacman -Syy

# Install base packages

sudo pacman -S --noconfirm base-devel wget jq
sudo pacman -S --noconfirm exa bat ripgrep fd bottom sad bc gum git-delta tldr duf gping tokei hyperfine gitui fzf
sudo pacman -S --noconfirm fish fzf git kitty vim

# Python

sudo pacman -S --noconfirm python-pip
pyloc=$(sudo fd . /usr/lib/ --type f --max-depth 2 | grep "EXTERNALLY-MANAGED" | head -1)
sudo rm -rf "$pyloc"
pip intall xhibit
echo -e "\n" | sudo syslog-ng-update-virtualenv

# nodeJS

sudo pacman -S --noconfirm nodejs npm

# Install YAY

git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin/
makepkg -si --noconfirm
cd $HOME
rm -rf yay-bin

# Install Fonts

sudo pacman -S --noconfirm ttf-fantasque-sans-mono noto-fonts-emoji noto-fonts
yay -S --noconfirm ttf-fantasque-nerd ttf-ms-fonts ttf-vista-fonts

# Install spice-vdagent

sudo pacman -S --noconfirm spice-vdagent-openrc
sudo rc-update add spice-vdagent
sudo rc-service spice-vdagent start

# INSTALL AND COPY NNN FM SETTINGS

sudo pacman -S --noconfirm trash-cli tree
git clone https://github.com/jarun/nnn
cd nnn
sudo make O_NERD=1 install
cd ..
rm -rf nnn

mkdir -p .config/nnn/plugins
cd .config/nnn/plugins/
curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
cd
cp -r $HOME/setup/scripts/misc/preview-tui $HOME/.config/nnn/plugins

# COPY BASH VIM settings TO HOME

cp -r $HOME/setup/configs/.bashrc $HOME
cp -r $HOME/setup/configs/.vimrc $HOME

# COPY BASH VIM settings TO ROOT

sudo cp $HOME/.bashrc /root/
sudo cp $HOME/.vimrc /root/

# COPY FISH SHELL SETTINGS

fish -c "exit"
cp -r $HOME/setup/configs/config.fish $HOME/.config/fish/

# COPY KITTY SETTINGS

cp -r $HOME/setup/configs/kitty $HOME/.config/

# Locale Fix

sudo sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo su -c 'locale-gen'
sudo su -c 'echo "LANG=en_US.UTF-8" >>/etc/locale.conf'

# Dmenu

cd $HOME/setup/configs/DWM/dmenu/
sudo make clean install
cd
echo "Done Installing DEMNU!"
echo ""

# Clipboard Support

sudo pacman -S --noconfirm clipmenu
echo "## Clipmenu
clipmenud &
" >>$HOME/.xprofile

# CHANGE DEFAULT SHELL

sudo usermod --shell /bin/fish "$USER"
echo "Changed default shell!"

# CONFIGURING GIT

git config --global user.name -
git config --global user.email -

echo "[core]
    pager = delta --syntax-theme 'gruvbox-dark'

[interactive]
    diffFilter = delta --color-only --features=interactive

[delta]
    features = decorations

[delta \"interactive\"]
    keep-plus-minus-markers = false

[delta \"decorations\"]
    commit-decoration-style = blue ol
    commit-style = raw
    file-style = omit
    hunk-header-decoration-style = blue box
    hunk-header-file-style = red
    hunk-header-line-number-style = \"#067a00\"
    hunk-header-style = file line-number syntax
" >>$HOME/.gitconfig

# Editor

pip install neovim black flake8
sudo npm i -g neovim typescript typescript-language-server pyright vscode-langservers-extracted ls_emmet @fsouza/prettierd eslint_d diagnostic-languageserver bash-language-server browser-sync
pip uninstall -y cmake

sudo pacman -S --noconfirm cmake ninja tree-sitter tree-sitter-cli xclip shfmt meson fortune-mod
sudo pacman -S --noconfirm neovim
cp -r ~/setup/configs/nvim ~/.config

# Get DS

sudo pacman -S --noconfirm github-cli
git clone https://github.com/glowfi/DS

# Browser

yay -S --noconfirm librewolf-bin
rm -rf $HOME/.librewolf/

###### Start Librewolf ######

sudo -u "$USER" librewolf --headless &
sleep 6
pkill -u "$USER" librewolf

### Copy a script to start librewolf without volume auto adjust
echo '!/bin/bash

"$HOME/.local/bin/libw" "librewolf:$(date +%s)" "default-default" "librewolf"' >>openlibrewolf
chmod +x openlibrewolf
sudo mv openlibrewolf /usr/bin/

mkdir -p $HOME/.local/bin/
cp -r $HOME/setup/scripts/system/libw $HOME/.local/bin/
chmod +x $HOME/.local/bin/libw

### Add Extensions

extensions=("https://addons.mozilla.org/firefox/downloads/latest/clearurls/latest.xpi" "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes/latest.xpi")

for i in "${extensions[@]}"; do
	c=$(cat /usr/lib/librewolf/distribution/policies.json | grep -n "Install" | head -1 | awk -F":" '{print $1}' | xargs)
	sudo sed -i "${c} a \"${i}\"," /usr/lib/librewolf/distribution/policies.json
done

###### Arkenfox Profile ######

# Get Default-release Location
findLocation=$(find ~/.librewolf/ | grep -E "default-default" | head -1)

# Go to default-release profile
cd "$findLocation"

# User CSS
mkdir chrome
cd chrome
cd ..

# Get Arkenfox user.js
wget https://raw.githubusercontent.com/arkenfox/user.js/master/user.js -O user.js

# Settings
echo -e "\n" >>user.js
echo "// ****** OVERRIDES ******" >>user.js
echo "" >>user.js
echo 'user_pref("keyword.enabled", true);' >>user.js
echo "user_pref('toolkit.legacyUserProfileCustomizations.stylesheets', true);" >>user.js
echo 'user_pref("general.smoothScroll",                                       true);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.enabled",                    true);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant",  600);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",      650);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         25);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",      2.0);' >>user.js
echo 'user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",     250);' >>user.js
echo 'user_pref("general.smoothScroll.currentVelocityWeighting",              1.0);' >>user.js
echo 'user_pref("general.smoothScroll.stopDecelerationWeighting",             1.0);' >>user.js
echo 'user_pref("mousewheel.default.delta_multiplier_y",                      300);' >>user.js

cd

### Performance and Security

echo ""
echo "------------------------------------------------------------------------------"
echo "--------------CONFIGURING PERFORMANCE AND SECURITY...-------------------------"
echo "------------------------------------------------------------------------------"
echo ""

# Setup APPARMOR

sudo echo "write-cache" | sudo tee -a /etc/apparmor/parser.conf >/dev/null
sudo echo "Optimize=compress-fast" | sudo tee -a /etc/apparmor/parser.conf >/dev/null

# Install APPARMOR

sudo pacman -S --noconfirm apparmor-openrc
sudo rc-update add apparmor
sudo rc-service apparmor start

# Add flags in GRUB config for apparmor

getGrubDefaultArgs=$(cat /etc/default/grub | grep -n "GRUB_CMDLINE_LINUX_DEFAULT")
getLineNumber=$(echo "$getGrubDefaultArgs" | cut -d ":" -f1 | xargs)
getOldArgs=$(cat /etc/default/grub | grep "GRUB_CMDLINE_LINUX_DEFAULT" | sed '$ s/.$//')
req="lsm=landlock,lockdown,yama,apparmor,bpf"

new="${getOldArgs} ${req}\""
rep=$(echo "$new" | sed 's/\//\\\//g')
sudo sed -i "${getLineNumber}s/.*/${rep}/" /etc/default/grub

sudo grub-mkconfig -o /boot/grub/grub.cfg

# INCREASE VIRTUAL MEMORY

sudo echo "vm.max_map_count=2147483642" | sudo tee -a /etc/sysctl.d/90-override.conf >/dev/null

# SETUP SSH

sudo pacman -S --noconfirm openssh-openrc sshguard-openrc x11-ssh-askpass

sudo rm -rf /etc/sshguard.conf
sudo echo '# Full path to backend executable (required, no default)
BACKEND="/usr/lib/sshguard/sshg-fw-nft-sets"

# Log reader command (optional, no default)
LOGREADER="LANG=C /usr/bin/journalctl -afb -p info -n1 -t sshd -t vsftpd -o cat"

# How many problematic attempts trigger a block
THRESHOLD=20
# Blocks last at least 180 seconds
BLOCK_TIME=180
# The attackers are remembered for up to 3600 seconds
DETECTION_TIME=3600

# Blacklist threshold and file name
BLACKLIST_FILE=100:/var/db/sshguard/blacklist.db

# IPv6 subnet size to block. Defaults to a single address, CIDR notation. (optional, default to 128)
IPV6_SUBNET=64
# IPv4 subnet size to block. Defaults to a single address, CIDR notation. (optional, default to 32)
IPV4_SUBNET=24' | sudo tee -a /etc/sshguard.conf >/dev/null

# SECURITY FEATURES

sudo echo "# Disable webcam
blacklist uvcvideo

# Disable bluetooth
blacklist btusb
blacklist bluetooth
" | sudo tee -a /etc/modprobe.d/blacklist.conf >/dev/null

# Better IO Scheduler

echo '# set scheduler for NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="bfq"
# set scheduler for SSD and eMMC
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="bfq"
# set scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"' | sudo tee -a /etc/udev/rules.d/60-ioschedulers.rules

# PERFORMANCE AND SECURITY SETTINGS

sudo sed -i 's/^umask.*/umask\ 077/' /etc/profile
sudo mkdir -p /etc/modules-load.d
sudo touch /etc/modules-load.d/bbr.conf
sudo echo "tcp_bbr" | sudo tee -a /etc/modules-load.d/bbr.conf >/dev/null

echo "# The swappiness sysctl parameter represents the kernel's preference (or avoidance) of swap space. Swappiness can have a value between 0 and 100, the default value is 60.
# A low value causes the kernel to avoid swapping, a higher value causes the kernel to try to use swap space. Using a low value on sufficient memory is known to improve responsiveness on many systems.
vm.swappiness=10

# The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache).
# Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
vm.vfs_cache_pressure=50

# Contains, as a percentage of total available memory that contains free pages and reclaimable
# pages, the number of pages at which a process which is generating disk writes will itself start
# writing out dirty data (Default is 20).
vm.dirty_ratio = 5

# Contains, as a percentage of total available memory that contains free pages and reclaimable
# pages, the number of pages at which the background kernel flusher threads will start writing out
# dirty data (Default is 10).
vm.dirty_background_ratio = 5

# This tunable is used to define when dirty data is old enough to be eligible for writeout by the
# kernel flusher threads.  It is expressed in 100'ths of a second.  Data which has been dirty
# in-memory for longer than this interval will be written out next time a flusher thread wakes up
# (Default is 3000).
vm.dirty_expire_centisecs = 3000

# The kernel flusher threads will periodically wake up and write old data out to disk.  This
# tunable expresses the interval between those wakeups, in 100'ths of a second (Default is 500).
vm.dirty_writeback_centisecs = 1500

# This action will speed up your boot and shutdown, because one less module is loaded. Additionally disabling watchdog timers increases performance and lowers power consumption
# Disable NMI watchdog
kernel.nmi_watchdog = 0

# Enable the sysctl setting kernel.unprivileged_userns_clone to allow normal users to run unprivileged containers.
kernel.unprivileged_userns_clone=1

# To hide any kernel messages from the console
kernel.printk = 3 3 3 3

# Restricting access to kernel logs
kernel.dmesg_restrict = 1

# Restricting access to kernel pointers in the proc filesystem
kernel.kptr_restrict = 2

# Disable Kexec, which allows replacing the current running kernel.
kernel.kexec_load_disabled = 1

# Restricts the BPF JIT compiler to root only. This prevents a lot of possible attacks against the JIT compiler such as heap spraying.
kernel.unprivileged_bpf_disabled=1

# Hardens the JIT compiler against certain attacks such as heap spraying attacks.
net.core.bpf_jit_harden=2

# Increasing the size of the receive queue.
# The received frames will be stored in this queue after taking them from the ring buffer on the network card.
# Increasing this value for high speed cards may help prevent losing packets:
net.core.netdev_max_backlog = 16384

# Increase the maximum connections
#The upper limit on how many connections the kernel will accept (default 128):
net.core.somaxconn = 8192

# Increase the memory dedicated to the network interfaces
# The default the Linux network stack is not configured for high speed large file transfer across WAN links (i.e. handle more network packets) and setting the correct values may save memory resources:
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.core.optmem_max = 65536
net.ipv4.tcp_rmem = 4096 1048576 2097152
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192

# Enable TCP Fast Open
# TCP Fast Open is an extension to the transmission control protocol (TCP) that helps reduce network latency
# by enabling data to be exchanged during the sender’s initial TCP SYN [3].
# Using the value 3 instead of the default 1 allows TCP Fast Open for both incoming and outgoing connections:
net.ipv4.tcp_fastopen = 3

# Enable BBR
# The BBR congestion control algorithm can help achieve higher bandwidths and lower latencies for internet traffic
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = bbr

# TCP SYN cookie protection
# Helps protect against SYN flood attacks. Only kicks in when net.ipv4.tcp_max_syn_backlog is reached:
net.ipv4.tcp_syncookies = 1

# Protect against tcp time-wait assassination hazards, drop RST packets for sockets in the time-wait state. Not widely supported outside of Linux, but conforms to RFC:
net.ipv4.tcp_rfc1337 = 1

# By enabling reverse path filtering, the kernel will do source validation of the packets received from all the interfaces on the machine. This can protect from attackers that are using IP spoofing methods to do harm.
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# To use the new FQ-PIE Queue Discipline (>= Linux 5.6) in systems with systemd (>= 217), will need to replace the default fq_codel.
net.core.default_qdisc = fq_pie" | sudo tee -a /etc/sysctl.d/99-sysctl-performance-tweaks.conf >/dev/null

# Firewall

sudo pacman -S --noconfirm iptables-openrc nftables-openrc
sudo rm -rf /etc/nftables.conf

echo "#!/usr/sbin/nft -f
# vim:set ts=2 sw=2 et:

flush ruleset

table ip filter {
  chain DOCKER-USER {
    mark set 1
  }
  chain LIBVIRT_FWI{
    mark set 1
  }
  chain LIBVIRT_FWO{
    mark set 1
  }
  chain LIBVIRT_FWX{
    mark set 1
  }
  chain LIBVIRT_INP{
    mark set 1
  }
  chain LIBVIRT_OUT{
    mark set 1
  }
}

table inet my_table {
	chain my_input {
		type filter hook input priority 0; policy drop;

		iif lo accept comment \"Accept any localhost traffic\"
		ct state invalid drop comment \"Drop invalid connections\"

		meta l4proto icmp icmp type echo-request limit rate over 10/second burst 4 packets drop comment \"No ping floods\"
		meta l4proto ipv6-icmp icmpv6 type echo-request limit rate over 10/second burst 4 packets drop comment \"No ping floods\"

		ct state established,related accept comment \"Accept traffic originated from us\"

		# Allow incoming KDE Connect traffic
        ct state new,established,related accept

		meta l4proto ipv6-icmp icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, mld-listener-query, mld-listener-report, mld-listener-reduction, nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, ind-neighbor-solicit, ind-neighbor-advert, mld2-listener-report } accept comment \"Accept ICMPv6\"
		meta l4proto ipv6-icmp icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, mld-listener-query, mld-listener-report, mld-listener-reduction, nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, ind-neighbor-solicit, ind-neighbor-advert, mld2-listener-report } accept comment \"Accept ICMPv6\"
		meta l4proto icmp icmp type { destination-unreachable, router-solicitation, router-advertisement, time-exceeded, parameter-problem } accept comment \"Accept ICMP\"
		ip protocol igmp accept comment \"Accept IGMP\"

		tcp dport ssh ct state new limit rate 15/minute accept comment \"Avoid brute force on SSH\"

		udp dport mdns ip6 daddr ff02::fb accept comment \"Accept mDNS\"
		udp dport mdns ip daddr 224.0.0.251 accept comment \"Accept mDNS\"

		udp sport 1900 udp dport >= 1024 ip6 saddr { fd00::/8, fe80::/10 } meta pkttype unicast limit rate 4/second burst 20 packets accept comment \"Accept UPnP IGD port mapping reply\"
		udp sport 1900 udp dport >= 1024 ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 } meta pkttype unicast limit rate 4/second burst 20 packets accept comment \"Accept UPnP IGD port mapping reply\"

		udp sport netbios-ns udp dport >= 1024 meta pkttype unicast ip6 saddr { fd00::/8, fe80::/10 } accept comment \"Accept Samba Workgroup browsing replies\"
		udp sport netbios-ns udp dport >= 1024 meta pkttype unicast ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 } accept comment \"Accept Samba Workgroup browsing replies\"

		counter comment \"Count any other traffic\"
	}

	chain my_forward {
		type filter hook forward priority security; policy drop;
  		mark 1 accept
		# Drop everything forwarded to that's not from docker us. We do not forward. That is routers job.
	}

	chain my_output {
		type filter hook output priority 0; policy accept;
		# Accept every outbound connection
	}

}

table inet dev {
    set blackhole {
        type ipv4_addr;
        flags dynamic, timeout;
        size 65536;
    }

    chain input {
        ct state new tcp dport 443 \\
                meter flood size 128000 { ip saddr timeout 10s limit rate over 10/second } \\
                add @blackhole { ip saddr timeout 1m }

        ip saddr @blackhole counter drop
    }
}" | sudo tee -a /etc/nftables.conf >/dev/null

sudo chmod 700 /etc/{iptables,nftables.conf}
sudo rc-service nftables save
sudo rc-update add nftables

### Install dnscrypt-proxy
sudo pacman -S --noconfirm dnscrypt-proxy-openrc
sudo pip install requests

### Setup dnscrypt-proxy
getServerNames=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "server_names" | head -1 | xargs)
getLineNumber=$(echo "$getServerNames" | cut -d":" -f1)
newServers="#server_names = ['quad9-dnscrypt-ip4-filter-ecs-pri','sfw.scaleway-fr','dnscrypt-de-blahdns-ipv4','dnscrypt-de-blahdns-ipv6','quad9-doh-ip6-port443-filter-ecs-pri','quad9-doh-ip6-port5053-filter-ecs-pri','ahadns-doh-nl','ahadns-doh-la','ams-dnscrypt-nl','scaleway-ams','dnscry.pt-amsterdam-ipv4','dnsforge.de','oszx','libredns-noads']"
sudo sed -i "${getLineNumber}s/.*/${newServers}/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

newListenAddresses="listen_addresses = ['127.0.0.1:5300', '[::1]:5300']"
getListenAddresses=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "listen_addresses" | head -1 | xargs)
getLineNumber=$(echo "$getListenAddresses" | cut -d":" -f1)
sudo sed -i "${getLineNumber}s/.*/${newListenAddresses}/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

find="listen_addresses = ['127.0.0.1:53']"
getListenAddresses=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "listen_addresses" | tail -2 | head -1 | xargs)
getLineNumber=$(echo "$getListenAddresses" | cut -d":" -f1)
sudo sed -i "${getLineNumber}d" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

rep="require_dnssec = true"
getLine=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "require_dnssec = false" | head -1 | xargs)
getLineNumber=$(echo "$getLine" | cut -d":" -f1)
sudo sed -i "${getLineNumber}s/.*/${rep}/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

rep="doh_servers = false"
getLine=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "doh_servers = true" | head -1 | xargs)
getLineNumber=$(echo "$getLine" | cut -d":" -f1)
sudo sed -i "${getLineNumber}s/.*/${rep}/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

getReq=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "netprobe_timeout" | head -1 | xargs)
getLineNumber=$(echo "$getReq" | cut -d":" -f1)
rep="netprobe_timeout = -1"
sudo sed -i "${getLineNumber}s/.*/${rep}/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

getReq=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "http3" | head -1 | xargs)
getLineNumber=$(echo "$getReq" | cut -d":" -f1)
rep="http3 = true"
sudo sed -i "${getLineNumber}s/.*/${rep}/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

getReq=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "force_tcp" | head -1 | xargs)
getLineNumber=$(echo "$getReq" | cut -d":" -f1)
rep="force_tcp = true"
sudo sed -i "${getLineNumber}s/.*/${rep}/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

### Start dnscrypt-proxy at startup
sudo rc-update add dnscrypt-proxy

### Install dnsmasq
sudo pacman -S --noconfirm dnsmasq-openrc

### Setup dnsmasq
sudo echo '
port=5353
bogus-priv
no-resolv
domain-needed
strict-order
clear-on-reload

server=::1#5300
server=127.0.0.1#5300
listen-address=::1,127.0.0.1

conf-file=/usr/share/dnsmasq/trust-anchors.conf
dnssec' | sudo tee -a /etc/dnsmasq.conf >/dev/null

### Start dnsmasq at startup
sudo rc-update add dnsmasq

### Edit /etc/resolv.conf
sudo chattr -i /etc/resolv.conf
sudo truncate -s 0 /etc/resolv.conf
sudo echo '### Custom DNS Resolver
nameserver ::1
nameserver 127.0.0.1
options edns0 single-request-reopen' | sudo tee -a /etc/resolv.conf >/dev/null
sudo chattr +i /etc/resolv.conf

### Load settings

echo "[apps/light-locker]
idle-hint=false
late-locking=true
lock-after-screensaver=uint32 5
lock-on-lid=true
lock-on-suspend=true

[net/connman/gtk]
launch-to-tray=true
openconnect-use-fsid-by-default=false
status-icon-enabled=true

[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Artix-dark'

[org/gnome/epiphany]
default-search-engine='DuckDuckGo'
homepage-url='about:blank'

[org/gnome/epiphany/reader]
color-scheme='dark'

[org/mate/caja/desktop]
computer-icon-visible=true
font='Roboto 11'

[org/mate/caja/preferences]
show-image-thumbnails='always'

[org/mate/caja/window-state]
geometry='800x550+557+234'
maximized=false
start-with-sidebar=true
start-with-status-bar=true
start-with-toolbar=true

[org/mate/desktop/accessibility/keyboard]
bouncekeys-beep-reject=true
bouncekeys-delay=300
bouncekeys-enable=false
enable=false
feature-state-change-beep=false
mousekeys-accel-time=1200
mousekeys-enable=false
mousekeys-init-delay=160
mousekeys-max-speed=750
slowkeys-beep-accept=true
slowkeys-beep-press=true
slowkeys-beep-reject=false
slowkeys-delay=300
slowkeys-enable=false
stickykeys-enable=false
stickykeys-latch-to-lock=true
stickykeys-modifier-beep=true
stickykeys-two-key-off=true
timeout=120
timeout-enable=false
togglekeys-enable=false

[org/mate/desktop/applications/terminal]
exec='kitty'

[org/mate/desktop/background]
picture-filename='/usr/share/backgrounds/GradientGlowBlue.jpg'
picture-options='zoom'

[org/mate/desktop/font-rendering]
hinting='full'

[org/mate/desktop/interface]
document-font-name='Roboto 11'
font-name='Roboto 11'
gtk-color-scheme='base_color:#2B2B2C\nfg_color:#e3e3e3\ntooltip_fg_color:#eaeaea\nselected_bg_color:#4080fb\nselected_fg_color:#eaeaea\ntext_color:#e3e3e3\nbg_color:#323131\ninsensitive_bg_color:#434446\ntooltip_bg_color:#343434\nlink_color:#4080fb'
gtk-theme='Artix-dark'
icon-theme='matefaenzadark'
monospace-font-name='Roboto Mono 11'

[org/mate/desktop/keybindings/custom0]
action='dmenu_run'
binding='<Mod4>p'
name='app_menu'

[org/mate/desktop/keybindings/custom1]
action='clipmenu'
binding='<Mod4>e'
name='clip_menu'

[org/mate/desktop/keybindings/custom2]
action='openlibrewolf'
binding='<Mod4>b'
name='librewolf'

[org/mate/desktop/media-handling]
automount-open=false

[org/mate/desktop/peripherals/mouse]
cursor-theme='Premium'

[org/mate/desktop/session]
session-start=1700055777

[org/mate/marco/general]
num-workspaces=1
theme='Spidey'
titlebar-font='Roboto Bold 11'

[org/mate/marco/global-keybindings]
run-command-terminal='<Mod4>t'

[org/mate/marco/window-keybindings]
close='<Primary><Shift>q'
move-to-monitor-n='<Mod4>Up'
move-to-side-n='disabled'
move-to-side-s='disabled'
tile-to-corner-nw='<Mod4>Up'
tile-to-corner-sw='<Mod4>Down'
tile-to-side-e='<Mod4>Right'
tile-to-side-w='<Mod4>Left'
toggle-maximized='<Shift><Mod4>f'

[org/mate/notification-daemon]
theme='standard'

[org/mate/panel/general]
locked-down=false
object-id-list=['main-menu', 'show-desktop', 'irc', 'window-list', 'drive-mounter', 'notification-area', 'clock-applet', 'object-0', 'object-2']
toplevel-id-list=['bottom']

[org/mate/panel/objects/browser]
launcher-location='/usr/share/applications/org.gnome.Epiphany.desktop'
object-type='launcher'
panel-right-stick=false
position=1
toplevel-id='bottom'

[org/mate/panel/objects/clock-applet]
applet-iid='ClockAppletFactory::ClockApplet'
object-type='applet'
panel-right-stick=true
position=0
toplevel-id='bottom'

[org/mate/panel/objects/clock-applet/prefs]
custom-format=''
format='24-hour'
show-date=false

[org/mate/panel/objects/drive-mounter]
applet-iid='DriveMountAppletFactory::DriveMountApplet'
object-type='applet'
panel-right-stick=true
position=2
toplevel-id='bottom'

[org/mate/panel/objects/indicators]
applet-iid='IndicatorAppletCompleteFactory::IndicatorAppletComplete'
object-type='applet'
panel-right-stick=true
position=2
toplevel-id='bottom'

[org/mate/panel/objects/irc]
launcher-location='/usr/share/applications/io.github.Hexchat.desktop'
object-type='launcher'
panel-right-stick=false
position=1
toplevel-id='bottom'

[org/mate/panel/objects/main-menu]
object-type='menu'
toplevel-id='bottom'

[org/mate/panel/objects/notification-area]
applet-iid='NotificationAreaAppletFactory::NotificationArea'
object-type='applet'
panel-right-stick=true
position=1
toplevel-id='bottom'

[org/mate/panel/objects/object-0]
launcher-location='/usr/share/applications/kitty.desktop'
object-type='launcher'
panel-right-stick=false
position=-1
toplevel-id='bottom'

[org/mate/panel/objects/object-1]
launcher-location='/usr/share/applications/librewolf.desktop'
object-type='launcher'
panel-right-stick=false
position=-1
toplevel-id='bottom'

[org/mate/panel/objects/object-2]
launcher-location='/usr/share/applications/librewolf.desktop'
object-type='launcher'
panel-right-stick=false
position=-1
toplevel-id='bottom'

[org/mate/panel/objects/show-desktop]
applet-iid='WnckletFactory::ShowDesktopApplet'
object-type='applet'
panel-right-stick=false
position=1
toplevel-id='bottom'

[org/mate/panel/objects/terminal]
launcher-location='/usr/share/applications/mate-terminal.desktop'
object-type='launcher'
panel-right-stick=false
position=1
toplevel-id='bottom'

[org/mate/panel/objects/window-list]
applet-iid='WnckletFactory::WindowListApplet'
object-type='applet'
panel-right-stick=false
position=2
toplevel-id='bottom'

[org/mate/panel/toplevels/bottom]
orientation='bottom'
size=32
y=1048
y-bottom=0

[org/mate/pluma]
auto-indent=true
color-scheme='Artix-dark'
insert-spaces=true

[org/mate/power-manager]
backlight-battery-reduce=false

[org/mate/screensaver]
lock-enabled=false
mode='blank-only'
themes='[]'

[org/mate/settings-daemon/plugins/media-keys]
home='<Mod4>f'
www='<Mod4>b'

[org/mate/terminal/global]
use-menu-accelerators=false
use-mnemonics=false

[org/mate/terminal/profiles/default]
background-color='#000000000000'
bold-color='#000000000000'
foreground-color='#AAAAAAAAAAAA'
palette='#2E2E34343636:#CCCC00000000:#4E4E9A9A0606:#C4C4A0A00000:#34346565A4A4:#757550507B7B:#060698209A9A:#D3D3D7D7CFCF:#555557575353:#EFEF29292929:#8A8AE2E23434:#FCFCE9E94F4F:#72729F9FCFCF:#ADAD7F7FA8A8:#3434E2E2E2E2:#EEEEEEEEECEC'
scrollback-unlimited=true
use-theme-colors=false
visible-name='Default'" >>tmp
dconf load / <tmp
rm tmp

# DELETE CACHED PASSWORD

sudo sed -i '72d' /etc/sudoers
