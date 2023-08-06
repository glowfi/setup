#!/bin/bash

### PERFORMANCE AND SECURITY

echo ""
echo "------------------------------------------------------------------------------"
echo "--------------CONFIGURING PERFORMANCE AND SECURITY...-------------------------"
echo "------------------------------------------------------------------------------"
echo ""

# ENABLE ZRAM

install "zramd" "yay"
sudo sed -i '2s/.*/ALGORITHM=zstd/' /etc/default/zramd
sudo sed -i '8s/.*/MAX_SIZE=32768/' /etc/default/zramd
sudo systemctl enable --now zramd

# SETUP APPARMOR

sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 lsm=landlock,lockdown,yama,apparmor,bpf"/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
install "apparmor" "pac"
sudo systemctl enable --now apparmor.service

# INCREASE VIRTUAL MEMORY

sudo echo "vm.max_map_count=2147483642" | sudo tee -a /etc/sysctl.d/90-override.conf >/dev/null

# NETWORKING SETTINGS

sudo echo 'DNSOverTLS=yes
LLMNR=no' | sudo tee -a /etc/systemd/resolved.conf >/dev/null

# SETUP SSH

install "openssh sshguard x11-ssh-askpass" "pac"

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
blacklist uvcvideo" | sudo tee -a /etc/modprobe.d/blacklist.conf >/dev/null

# Better IO Scheduler

echo '# set scheduler for NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# set scheduler for SSD and eMMC
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# set scheduler for rotating disks
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"' | sudo tee -a /etc/udev/rules.d/60-ioschedulers.rules

# PERFORMANCE AND SECURITY SETTINGS

sudo sed -i 's/^umask.*/umask\ 077/' /etc/profile
sudo echo "tcp_bbr" | sudo tee -a /etc/modules-load.d/bbr.conf >/dev/null
sudo echo "write-cache" | sudo tee -a /etc/apparmor/parser.conf >/dev/null

echo "# The swappiness sysctl parameter represents the kernel's preference (or avoidance) of swap space. Swappiness can have a value between 0 and 100, the default value is 60.
# A low value causes the kernel to avoid swapping, a higher value causes the kernel to try to use swap space. Using a low value on sufficient memory is known to improve responsiveness on many systems.
vm.swappiness=10

# The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache).
# Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
vm.vfs_cache_pressure=50

# This action will speed up your boot and shutdown, because one less module is loaded. Additionally disabling watchdog timers increases performance and lowers power consumption
# Disable NMI watchdog
#kernel.nmi_watchdog = 0

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
#vm.dirty_expire_centisecs = 3000

# The kernel flusher threads will periodically wake up and write old data out to disk.  This
# tunable expresses the interval between those wakeups, in 100'ths of a second (Default is 500).
vm.dirty_writeback_centisecs = 1500

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

# FIREWALL

for i in {1..5}; do yes | sudo pacman -S nftables && break || sleep 1; done
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
sudo systemctl enable --now nftables
sudo systemctl restart --now nftables

# SETUP dnscrypt-proxy

### Install dnscrypt-proxy
sudo pacman -S --noconfirm dnscrypt-proxy dnsmasq

### Put Server Name
getServerNames=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "server_names" | head -1 | xargs)
getLineNumber=$(echo "$getServerNames" | cut -d":" -f1)
newServers="server_names = ['quad9-dnscrypt-ip4-filter-ecs-pri','sfw.scaleway-fr','dnscrypt-de-blahdns-ipv4','dnscrypt-de-blahdns-ipv6','quad9-doh-ip6-port443-filter-ecs-pri','quad9-doh-ip6-port5053-filter-ecs-pri','ahadns-doh-nl','ahadns-doh-la','ams-dnscrypt-nl']"
sudo sed -i "${getLineNumber}s/.*/${newServers}/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

### Configure Listening Port
newListenAddresses="listen_addresses = ['127.0.0.1:53000', '[::1]:53000']"
getListenAddresses=$(cat /etc/dnscrypt-proxy/dnscrypt-proxy.toml | grep -n "listen_addresses" | head -1 | xargs)
getLineNumber=$(echo "$getListenAddresses" | cut -d":" -f1)
sudo sed -i "${getLineNumber}s/.*/${newListenAddresses}/" /etc/dnscrypt-proxy/dnscrypt-proxy.toml

### Start dnscrypt-proxy at startup
sudo systemctl start dnscrypt-proxy
sudo systemctl enable dnscrypt-proxy

### Setup dnsmasq
sudo echo '
no-resolv
server=::1#53000
server=127.0.0.1#53000
listen-address=::1,127.0.0.1

conf-file=/usr/share/dnsmasq/trust-anchors.conf
dnssec' | sudo tee -a /etc/dnsmasq.conf >/dev/null

### Start dnsmasq at startup
sudo systemctl start dnsmasq
sudo systemctl enable dnsmasq

### Edit /etc/resolv.conf
sudo chattr -i /etc/resolv.conf
sudo truncate -s 0 /etc/resolv.conf
sudo echo '### Custom DNS Resolver
nameserver ::1
nameserver 127.0.0.1
options edns0 single-request-reopen' | sudo tee -a /etc/resolv.conf >/dev/null
sudo chattr +i /etc/resolv.conf
