#!/bin/fish

function git_clone
    set repo $argv[1]
    set dest $argv[2]

    if test (count $argv) -gt 2
        set depth $argv[3]
    else
        set depth ""
    end

    if test -n "$depth"
        set depth_flag --depth $depth
    else
        set depth_flag
    end

    for i in (seq 1 5)
        if set -q depth_flag
            git clone $depth_flag $repo $dest && return 0
        else
            git clone $repo $dest && return 0
        end
        sleep 1
    end

    echo "Error: failed to clone $repo after 5 attempts" >&2
    return 1
end
