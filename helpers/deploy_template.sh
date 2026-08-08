#!/bin/bash

deploy_template() {
	TEMPLATE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/templates"
	local src="$1" dest="$2" mode="${3:-0644}"
	sudo install -D -m "$mode" "${TEMPLATE_DIR}/${src}" "$dest"
}
