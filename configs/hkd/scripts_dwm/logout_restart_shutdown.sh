#!/bin/sh

varInit=$(cat /proc/1/comm)
if [[ "$varInit" = "systemd" ]]; then
	ctl="systemctl"
else
	ctl="loginctl"
fi
case "$(printf "Lock\nSleep\nReboot\nShutdown" | dmenu -p "Choose:" -i)" in
'Lock') screenlocker ;;
'Sleep') "$ctl" suspend ;;
'Reboot') "$ctl" reboot ;;
'Shutdown') "$ctl" poweroff ;;
*) exit 1 ;;
esac
