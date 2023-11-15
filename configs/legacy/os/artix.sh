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
sudo pacman -S --noconfirm exa bat ripgrep fd bottom sad bc gum git-delta tldr duf gping tokei hyperfine fzf
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

# DELETE CACHED PASSWORD

sudo sed -i '72d' /etc/sudoers
