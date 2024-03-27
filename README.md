# Arch/Artix Setup

> Streamlined Arch/Artix Linux install script for installing KDE or DWM

![Coverpic](./pacman.png)

## Features

-   **Openrc** as init with **artix**
-   **SystemD** as init with **arch**
-   **Secure Boot**
-   **Zen** kernel
-   **Zstd** Compression
-   **Btrfs**
-   **Zram**
-   **LUKS** encryption
-   **Apparmor**
-   **Dnscrypt**
-   **Some tweaks for performance**
-   **Hardened SSH**
-   **Hardened Firewall**
-   **Hardened browser** with custom settings and user policy

## KDE

#### Features :

-   Minimal KDE install with minimal packages.
<hr/>

## DWM

#### Features :

-   Minimal DWM install.
-   Enabled Emoji support

#### Installed Patches List :

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
-   fade inactive
<hr/>

**Misc Patches**

-   fullscreen
-   always center
-   ewmhtags
-   focusonnetactive

## How to Install

**Base install**

> Connect to internet before running the below commands

```sh

pacman -Sy archlinux-keyring git
git clone https://github.com/glowfi/setup
./setup/run_1.sh

```

**DE/WM/Server install**

> Restart and login as the new user created from above script and run the below commands

```sh
cd
git clone https://github.com/glowfi/setup
./setup/run_2.sh

```
