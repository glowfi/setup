#!/bin/bash

filez="$1"
filezz="${filez#?}"
curd=$(pwd)
file="${curd}/${filezz}"

up="$2"
down="$3"
codez="$4"
qu=$((down + 1))

if test -f "$file"; then
	if [[ ! -z "${up}" && ! -z "${down}" ]]; then
		if [[ -z "${codez}" ]]; then
			code=$(trans --list-all | fzf | awk '{print $1}')
		else
			code=${codez}
		fi
		text=$(sed -n "${up},${down}p;${qu}q" "$file")
		if [[ ! -z "${code}" && ! -z "${text}" ]]; then
			echo -e ""
			echo -e "\e[1;31m Translating .... \e[0m"
			echo "$text" | trans -b -p :"${code}" -player mpv
		fi
	else
		echo "Provide Both Upper and Lower Bound Line Number!"
	fi
else
	echo "File does not exist!"
fi
