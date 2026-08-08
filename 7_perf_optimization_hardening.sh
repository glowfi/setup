#!/bin/bash

# Setup
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
source "${SCRIPT_DIR}/helpers/pkg_installer.sh"
source "${SCRIPT_DIR}/helpers/detect_init.sh"
source "${SCRIPT_DIR}/helpers/header.sh"
source "${SCRIPT_DIR}/helpers/lineinfile.sh"
source "${SCRIPT_DIR}/helpers/deploy_template.sh"

INIT_TYPE=$(detect_init)
DISTRO_TYPE="arch"
if [[ "$INIT_TYPE" != "systemD" ]]; then
	DISTRO_TYPE="artix"
fi

# OpenRC Performance optimization
if [[ "$DISTRO_TYPE" = "artix" ]]; then
	header "Configuring OpenRC performance settings"
	lineinfile /etc/rc.conf '#rc_parallel=' 'rc_parallel="YES"'
	lineinfile /etc/rc.conf '#rc_send_sighup=' 'rc_send_sighup="YES"'
	lineinfile /etc/rc.conf '#rc_timeout_stopsec=' 'rc_timeout_stopsec="10"'
	lineinfile /etc/rc.conf '#rc_send_sigkill=' 'rc_send_sigkill="YES"'
fi

# Configure ZRAM
header "Configuring ZRAM"

if [[ "$DISTRO_TYPE" == "arch" ]]; then
	install "zram-generator" "pac"
	sudo touch /etc/systemd/zram-generator.conf
	sudo tee -a /etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = 32768
compression-algorithm = zstd
EOF
else
	install "zram-openrc" "yay"
	sudo sed -i '1s/.*/zram_size="32G"/' /etc/conf.d/zram
fi

# Apparmor
header "Configuring AppArmor"

if [[ "$DISTRO_TYPE" = "arch" ]]; then
	install "apparmor" "pac"
else
	install "apparmor-openrc" "pac"
fi

sudo echo "write-cache" | sudo tee -a /etc/apparmor/parser.conf >/dev/null
sudo echo "Optimize=compress-fast" | sudo tee -a /etc/apparmor/parser.conf >/dev/null
if ! grep -q 'lsm=landlock,lockdown,yama,apparmor,bpf' /etc/default/grub; then
	sudo sed -i -E 's/^(GRUB_CMDLINE_LINUX_DEFAULT=".*)"/\1 lsm=landlock,lockdown,yama,apparmor,bpf"/' /etc/default/grub
fi

# Increase Virtual Memory
header "Increasing vm.max_map_count"
sudo echo "vm.max_map_count=2147483642" | sudo tee -a /etc/sysctl.d/90-override.conf >/dev/null

# Harden SystemD resolved
header "Hardening systemd-resolved"
if [[ "$DISTRO_TYPE" = "arch" ]]; then
	sudo echo 'DNSOverTLS=yes
LLMNR=no' | sudo tee -a /etc/systemd/resolved.conf >/dev/null
fi

# SSH
header "Setting up SSH"
if [[ "$DISTRO_TYPE" == "arch" ]]; then
	install "openssh sshguard x11-ssh-askpass" "pac"
else
	install "openssh-openrc sshguard-openrc x11-ssh-askpass" "pac"
fi
deploy_template "sshguard.conf.j2" /etc/sshguard.conf 0644

# Blacklist module
header "Blacklisting modules"
deploy_template "blacklist.conf.j2" /etc/modprobe.d/blacklist.conf 0644
echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf >/dev/null
sudo rmmod pcspkr 2>/dev/null || true

# System optimzation
header "Applying system optimizations"

deploy_template "60-ioschedulers.rules.j2" /etc/udev/rules.d/60-ioschedulers.rules 0644
sudo mkdir -p /etc/modules-load.d/

sudo sed -i 's/^umask.*/umask\ 077/' /etc/profile
echo "tcp_bbr" | sudo tee /etc/modules-load.d/bbr.conf >/dev/null

deploy_template "99-sysctl-performance-tweaks.conf.j2" /etc/sysctl.d/99-sysctl-performance-tweaks.conf 0644

# Power Management
install "poweralertd" "yay"
install "brightnessctl" "pac"
if [[ "$DISTRO_TYPE" == "arch" ]]; then
	install "power-profiles-daemon upower" "pac"
	sudo systemctl enable "power-profiles-daemon"
	sudo systemctl enable "upower"
	LOGIND_CONF=/etc/systemd/logind.conf
else
	install "power-profiles-daemon-openrc" "pac"
	install "upower-openrc" "yay"
	sudo rc-update add "power-profiles-daemon" default
	sudo rc-update add "upower" default
	LOGIND_CONF=/etc/elogind/logind.conf
fi

# Firewall
header "Setting up firewall"

if [[ "$DISTRO_TYPE" == "arch" ]]; then
	install "nftables" "pac"
else
	install "nftables-openrc iptables-openrc" "pac"
fi

deploy_template "nftables.conf.j2" /etc/nftables.conf 0600
sudo chmod 0700 /etc/nftables.conf

# Prevent docker's xt-compat rules from poisoning the save file
if [[ "$DISTRO_TYPE" == "artix" ]]; then
	lineinfile /etc/conf.d/nftables '^#?SAVE_ON_STOP=' 'SAVE_ON_STOP="no"'
	echo 'rc_need="nftables"' | sudo tee -a /etc/conf.d/docker >/dev/null
fi

# Timeshift
header "Setting up Timeshift"

[[ "$DISTRO_TYPE" == "arch" ]] && install "grub-btrfs" "pac"
install "timeshift" "yay"

if [[ "$DISTRO_TYPE" == "artix" ]]; then
	if [[ ! -f /usr/bin/grub-btrfsd ]]; then
		rm -rf /tmp/grub-btrfs
		git clone --depth 1 https://github.com/Antynea/grub-btrfs /tmp/grub-btrfs

		lineinfile /tmp/grub-btrfs/Makefile '^OPENRC' 'OPENRC ?= true'

		sudo make -C /tmp/grub-btrfs install
	fi
	rm -rf /tmp/grub-btrfs
fi

# Dnscrypt-proxy
header "Setting up dnscrypt-proxy"

if [[ "$DISTRO_TYPE" == "arch" ]]; then
	install "dnscrypt-proxy" "pac"
else
	install "dnscrypt-proxy-openrc" "pac"
	lineinfile /etc/conf.d/dnscrypt-proxy '^#?DNSCRYPT_PROXY_USER=' 'DNSCRYPT_PROXY_USER="root"'
	lineinfile /etc/dnscrypt-proxy/dnscrypt-proxy.toml '^#?\s*user_name\s*=' "user_name = 'nobody'"
	lineinfile /etc/init.d/dnscrypt-proxy '^command_args=' \
		'command_args="${DNSCRYPT_PROXY_OPTS:--config /etc/dnscrypt-proxy/dnscrypt-proxy.toml} --logfile /var/log/dnscrypt-proxy/dnsprox.txt"'
fi

dnscrypt_toml=/etc/dnscrypt-proxy/dnscrypt-proxy.toml
lineinfile "$dnscrypt_toml" '^#\sserver_names\s*=' \
	"server_names = ['quad9-dnscrypt-ip4-filter-ecs-pri','sfw.scaleway-fr','dnscrypt-de-blahdns-ipv4','dnscrypt-de-blahdns-ipv6','quad9-doh-ip6-port443-filter-ecs-pri','quad9-doh-ip6-port5053-filter-ecs-pri','ahadns-doh-nl','ahadns-doh-la','ams-dnscrypt-nl','scaleway-ams','dnscry.pt-amsterdam-ipv4','dnsforge.de','oszx','libredns-noads','mullvad-base-doh']"
lineinfile "$dnscrypt_toml" '^listen_addresses\s*=' "listen_addresses = ['127.0.0.1:53', '[::1]:53']"
lineinfile "$dnscrypt_toml" '^#?\s*require_dnssec\s*=' 'require_dnssec = true'
lineinfile "$dnscrypt_toml" '^netprobe_timeout\s*=' 'netprobe_timeout = -1'
lineinfile "$dnscrypt_toml" '^http3\s*=' 'http3 = true'
lineinfile "$dnscrypt_toml" '^force_tcp\s*=' 'force_tcp = true'

# Dnsmasq
header "Setting up dnsmasq"

if [[ "$DISTRO_TYPE" == "arch" ]]; then
	install "dnsmasq" "pac"
else
	install "dnsmasq-openrc" "pac"
fi

deploy_template "dnsmasq.conf.j2" /etc/dnsmasq.conf 0644

sudo chattr -i /etc/resolv.conf 2>/dev/null || true
deploy_template "resolv.conf.j2" /etc/resolv.conf 0644
sudo chattr +i /etc/resolv.conf

# Enable services
header "Enabling services"

if [[ "$DISTRO_TYPE" == "arch" ]]; then
	sudo systemctl enable systemd-zram-setup@zram0.service
	sudo systemctl daemon-reload
	sudo systemctl enable apparmor.service
	sudo grub-mkconfig -o /boot/grub/grub.cfg

	sudo systemctl enable nftables

	sudo systemctl enable grub-btrfsd
	sudo systemctl enable dnscrypt-proxy
	sudo systemctl enable dnsmasq
else
	sudo rc-update add zram default
	sudo rc-update add apparmor default
	sudo grub-mkconfig -o /boot/grub/grub.cfg

	sudo rc-update add nftables default
	sudo rm -f /var/lib/nftables/rules-save
	sudo nft -f /etc/nftables.conf
	sudo nft list ruleset | sudo tee /var/lib/nftables/rules-save >/dev/null

	sudo rc-update add grub-btrfsd default
	sudo rc-update add dnscrypt-proxy default
	sudo rc-update add dnsmasq default
fi
