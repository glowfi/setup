#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color

adb kill-server
adb tcpip 5555
adb connect 192.168.1.100:5555 || adb connect 192.168.1.100:5555
echo ""
echo -e "${RED}Waiting for accepting the promt ....${NC}"
echo ""
sleep 3
setsid scrcpy --display 2 --bit-rate 32M --window-title 'DexOnLinux' --turn-screen-off --stay-awake
