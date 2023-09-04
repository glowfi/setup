# Arch Setup

> Arch Linux install script for installing KDE or DWM

![Coverpic](./pacman.png)

## Features

-   Zen kernel
-   Btrfs
-   Zram
-   Apparmor
-   Dnscrypt
-   Tweaks for security and performance
-   Hardened SSH
-   Hardened Firewall
-   Hardened browser with custom settings and user policy

## KDE

Minimal KDE setup with minimal packages.

## DWM

Minimal DWM setup with minimal patches.

**DWM PATCHES**

> Enabled Emoji support

-   Cycle Layout
-   fibonacci_spiral
-   fibonacci_dwindle
-   3 column Layout

-   Fullscreen
-   always center
-   Fade Inactive

-   movestack
-   noborder
-   vanity gaps

**DMENU PATCHES**

> Enabled Emoji support

-   No Patches

**SLOCK PATCHES**

-   slock-message

**DWM BAR**

-   network (Connection status,upload and download speeds)
-   cpu ram disk usage
-   sound
-   brightness
-   battery
-   date and time

## INSTALLATION STEPS

**Base install**

> Ethernet or Wifi must be up before running the script below

```sh

pacman -Sy archlinux-keyring git
git clone https://github.com/glowfi/setup
./setup/run_1.sh

```

**DE/WM install**

> Restart before running the script below.

<b>Run the below commands from home directory only.</b>

```sh
cd
git clone https://github.com/glowfi/setup
./setup/run_2.sh

```
