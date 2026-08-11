# setup

Opinionated Arch/Artix installer. Boots from live ISO to a hardened,
ready-to-use KDE desktop in two scripts.

![Coverpic](./pacman.png)

## What you get

- **Arch** (systemd) or **Artix** (OpenRC) — auto-detected, same script
- Btrfs + zstd, zram, optional **LUKS full-disk encryption**
- Secure Boot, linux-zen kernel
- AppArmor, dnscrypt-proxy, nftables firewall, hardened SSH & browser
- Timeshift snapshots with grub-btrfs boot entries
- Minimal KDE Plasma

## Install

**1 — Base system** (from the live ISO, with internet):

```sh
pacman -Sy archlinux-keyring git
git clone https://github.com/glowfi/setup
./setup/run_1.sh
```

**2 — Desktop** (reboot, log in as your new user):

```sh
git clone https://github.com/glowfi/setup
cd setup && ./run_2.sh
```

Answer the prompts. Everything else is unattended.

## Notes

- Wipes the selected disk. Read the confirmation screen.
- Tested on: Arch (systemd), Artix (OpenRC).
