#!/bin/fish

function detect_init
    set -l os (uname -o)
    set -l varInit

    if test "$os" = Android
        set varInit "init.rc"
    else if not pidof -q systemd
        if test -f /sbin/openrc
            set varInit openrc
        else
            read -l varInit </proc/1/comm
            if test "$varInit" = systemd
                set varInit systemD
            end
        end
    else
        set varInit systemD
    end

    echo (string trim -- $varInit)
end
