#!/bin/bash

link="$1"
ftype="$2"

usage() {
	cat <<EOF
    -l   | --link          Provide the link of the file
    -f   | --ftype         Provide the file type
    -h   | --help          Prints help 

    ## EXAMPLE (To get a file)
    get.sh --link "https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz" --ftype "f" 

    ## EXAMPLE (To get contents of a file)
    get.sh --link "https://raw.githubusercontent.com/glowfi/xhibit-colorschemes/main/ex.py" --ftype "c" 

EOF
}

while [[ $# > 0 ]]; do
	case "$1" in

	-l | --link)
		link="$2"
		shift
		;;

	-f | --ftype)
		ftype="$2"
		shift
		;;

	--help | *)
		usage
		exit 1
		;;
	esac
	shift
done

if [[ "$ftype" == "f" ]]; then
	name=$(echo "$link" | awk -F"/" '{print $NF}')
	wget "$link" -O ~/"$name"
elif [[ "$ftype" == "c" ]]; then
	name=$(echo "$link" | awk -F"/" '{print $NF}')
	curl "$link" -o ~/"$name"
else
	echo "Provide a ftype! For downloading a file give f or just contens give c"
fi
