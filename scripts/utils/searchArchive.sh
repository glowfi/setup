#!/bin/bash

# Get package startCharacter
getCharacter=$(curl https://archive.archlinux.org/packages/ | grep "<a href" | sed -r 's#^.*<a href="([^"]+)">([^<]+)</a>.*$#\1\t\2#' | awk '{print $1}' | sed '1d' | sed 's/.$//')
selectCharacter=$(echo "$getCharacter" | fzf --prompt "Choose starting character of the package:")

if [[ "$selectCharacter" != "" ]]; then
	# List all packages of the startCharacter
	getPackages=$(curl "https://archive.archlinux.org/packages/${selectCharacter}/" | grep "<a href" | sed -r 's#^.*<a href="([^"]+)">([^<]+)</a>.*$#\1\t\2#' | awk '{print $1}' | sed '1d' | sed 's/.$//' | sort)
	selectPackage=$(echo "${getPackages}" | fzf -m --prompt "Choose a package(s):")

	if [[ "$selectPackage" != "" ]]; then

		mapfile -t arr < <(echo "$selectPackage")
		downloadLinks=""

		for i in "${arr[@]}"; do
			# Choose package version
			getPackageVersion=$(curl "https://archive.archlinux.org/packages/${selectCharacter}/${i}"/ | awk -F" " '{print $2 "= Date : " $3 "= Time: " $4 "= Size : " $5}' | sed -E 's/<+[^>]*>+//g' | sed 's/.*>/>/' | sed 's/^.//' | column -t -s '=' | head -n -2 | sed '1,4d' | sort -Vk1)
			selectPackageVersion=$(echo "$getPackageVersion" | fzf -m --cycle --prompt "Choose package version to install:" | awk '{print $1}')

			if [[ "${selectPackageVersion}" != "" ]]; then
				# Create Download string
				mapfile -t prr < <(echo "$selectPackageVersion")
				for j in "${prr[@]}"; do
					downloadLinks+="https://archive.archlinux.org/packages/${selectCharacter}/${i}/${j}\n"
				done
			fi

		done

		# Download packages
		dlStr=$(echo -e "${downloadLinks}")
		mapfile -t dlrr < <(echo "$dlStr")

		mkdir -p "$HOME/Downloads"
		cd "$HOME/Downloads/"

		for i in "${dlrr[@]}"; do
			wget "${i}"
		done
	fi

fi
