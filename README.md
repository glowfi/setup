# Arch/Artix Setup

> Arch/Artix Linux install script for installing KDE or DWM

![Coverpic](./pacman.png)

## Features

-   Zen kernel
-   Btrfs
-   Zram
-   LUKS encryption
-   Apparmor
-   Dnscrypt
-   Tweaks for security and performance
-   Hardened SSH
-   Hardened Firewall
-   Hardened browser with custom settings and user policy
-   Openrc as init with artix
-   SystemD as init with arch

## KDE

Minimal KDE setup with minimal packages.

## DWM

Minimal DWM setup with minimal patches.

**DWM PATCHES**

> Enabled Emoji support

**Layout Patches**

-   Cycle Layout
-   fibonacci_spiral
-   fibonacci_dwindle
-   3 column Layout
<hr/>

**UI Patches**

-   movestack
-   noborder
-   vanity gaps
-   Fade Inactive
<hr/>

**Misc Patches**

-   Fullscreen
-   always center

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

> Connect to internet before running the below script

```sh

pacman -Sy archlinux-keyring git
git clone https://github.com/glowfi/setup
./setup/run_1.sh

```

**DE/WM/Server install**

> Restart and login as the new user created from above script and run the script below

```sh
cd
git clone https://github.com/glowfi/setup
./setup/run_2.sh

```
