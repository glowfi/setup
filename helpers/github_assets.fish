#/bin/fish

function ghassets -d "Print release asset URLs; filters: plain = keep, -v:pat = ignore"
    if not set -q argv[1]
        echo "usage: ghassets owner/repo [filter|-v:filter]..." >&2
        return 1
    end

    set -l urls (curl -s "https://api.github.com/repos/$argv[1]/releases/latest" |
        grep '"browser_download_url"' | cut -d'"' -f4)

    for f in $argv[2..]
        if string match -q -- '-v:*' $f
            set urls (printf '%s\n' $urls | grep -ivE -- (string sub -s 4 -- $f))
        else
            set urls (printf '%s\n' $urls | grep -iE -- $f)
        end
    end

    printf '%s\n' $urls
end
