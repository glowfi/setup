#!/bin/bash

load_config() {
	local conf="${1:?load_config: path to config file required}"

	if [[ ! -f "$conf" ]]; then
		echo "config error: '$conf' not found." >&2
		exit 1
	fi

	# shellcheck disable=SC1090
	source "$conf"
}

require_config() {
	local missing=()
	local key

	for key in "$@"; do
		if [[ -z "${!key:-}" ]]; then
			missing+=("$key")
		fi
	done

	if ((${#missing[@]} > 0)); then
		echo "config error: missing required value(s): ${missing[*]}" >&2
		echo "(check ${CONFIG_FILE:-setup.conf} was generated correctly)" >&2
		exit 1
	fi
}
