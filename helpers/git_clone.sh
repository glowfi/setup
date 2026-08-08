#!/bin/bash

git_clone() {
	local repo="$1" dest="$2" depth="${3:-}"
	local depth_flag=()
	[[ -n "$depth" ]] && depth_flag=(--depth "$depth")

	for i in {1..5}; do
		git clone "${depth_flag[@]}" "$repo" "$dest" && return 0
		sleep 1
	done
	echo "Error: failed to clone $repo after 5 attempts" >&2
	return 1
}
