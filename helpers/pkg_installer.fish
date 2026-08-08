#!/bin/fish

# Script Directory
set SCRIPT_EXEC_DIR (cd (dirname (status --current-filename)) &>/dev/null; and pwd)

function install
    set -l packages (string split ' ' -- $argv[1])
    set -l repo pac
    if set -q argv[2]
        set repo $argv[2]
    end

    switch $repo
        case pac
            set -f cmd sudo pacman -S --noconfirm --needed
        case yay
            set -f cmd yay -S --noconfirm --needed
        case '*'
            echo "install: unknown repo '$repo'" >&2
            return 1
    end

    for i in (seq 5)
        $cmd $packages; and return 0
        sleep 1
    end

    echo "$packages" >>"$SCRIPT_EXEC_DIR/err.txt"
    echo "install: FAILED after 5 tries: $packages" >&2
    return 1
end
