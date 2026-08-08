#!/bin/bash

install_rate_mirrors() {
	local rate_mirror_dst="/usr/bin/rate-mirrors"

	local ver url dir
	ver=$(curl -s https://api.github.com/repos/westandskif/rate-mirrors/releases/latest |
		grep '"tag_name":' | cut -d'"' -f4)
	url="https://github.com/westandskif/rate-mirrors/releases/download/${ver}/rate-mirrors-${ver}-x86_64-unknown-linux-musl.tar.gz"
	dir="rate-mirrors-${ver}-x86_64-unknown-linux-musl"

	curl -fL --retry 5 -o /tmp/rate-mirrors.tar.gz "$url"
	tar -xzf /tmp/rate-mirrors.tar.gz -C /tmp
	mv "/tmp/${dir}/rate_mirrors" "$rate_mirror_dst"
	rm -rf /tmp/rate-mirrors.tar.gz "/tmp/${dir}"
}

sync_mirror() {
	local rate_mirror_dst="/usr/bin/rate-mirrors"
	local pacman_conf_dst="/etc/pacman.conf"
	local distro_type="$1"
	local repo_country="DE"

	local mirror_file_dst_arch
	if [[ "$distro_type" == "arch" ]]; then
		mirror_file_dst_arch="/etc/pacman.d/mirrorlist"
	else
		mirror_file_dst_arch="/etc/pacman.d/mirrorlist-arch"
	fi

	sudo sed -i 's/#Color/Color\nILoveCandy/' /etc/pacman.conf
	sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 16/' "$pacman_conf_dst"

	if [[ "$distro_type" == "arch" ]]; then
		pacman -Syy
		for i in {1..5}; do sudo pacman -S --noconfirm reflector && break || sleep 1; done

		timedatectl set-ntp true
		reflector --verbose -c DE --latest 5 --fastest 5 --protocol https --sort rate --save "$mirror_file_dst_arch"
	else
		install_rate_mirrors
		pacman -Syy
		for i in {1..5}; do pacman -S --noconfirm --needed artix-archlinux-support && break || sleep 1; done

		grep -q '^\[extra\]' /etc/pacman.conf || tee -a /etc/pacman.conf <<EOF
[extra]
Include = /etc/pacman.d/mirrorlist-arch
EOF

		pacman-key --populate archlinux

		rate-mirrors --protocol https --disable-comments-in-file --save=/etc/pacman.d/mirrorlist --allow-root artix
		pacman -Syy

		rate-mirrors --protocol https --disable-comments-in-file --save="${mirror_file_dst_arch}" --allow-root arch
		pacman -Syy
	fi
}
