# Arch Setup

> My streamline arch install script for installing KDE or DWM

![Coverpic](./pacman.png)

## Features

-   linux-zen kernel
-   btrfs
-   zram
-   apparmor

## KDE Build

> Minimal KDE with less bloat.

## DWM Build

> Minimal DWM build with less patches.

**DWM PATCHES**

-   3 column Layout
-   Fibonacci Layout
-   Cycle across layouts
-   Move Stack
-   vanity gaps
-   always center

**Emoji support added by installing libxft-bgra**

**DMENU PATCHES**

No patches (Vanilla)

**Emoji support by added installing libxft-bgra**

**SLOCK PATCHES**

-   slock-message

**DWM BAR**

-   Cpu Ram Disk usage
-   Sound
-   Brightness
-   Network
-   Date and Time

## INSTALLATION STEPS

**Connect to the Internet.Use iwctl if you are using wifi.
Your PC will restart after the below script finishes.**

```sh

pacman -Sy git
git clone https://github.com/glowfi/setup
./setup/run_1.sh

```

**After PC restarts login with your username and password .
Again connect to Internet.Use nmtui if you are using wifi.
Then,run the below command.**

```sh

git clone https://github.com/glowfi/setup
./setup/run_2.sh

```
