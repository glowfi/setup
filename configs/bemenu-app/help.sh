#!/usr/bin/env bash

createBemenu() {
	# Create bemenu
	touch bemenu
	cat <<'EOF' >>./bemenu
#!/usr/bin/env bash

input=$(echo "$(cat -)")
if [[ $(cat -s) =~ $'\n' ]]; then
	# echo -e "${input}" | LD_LIBRARY_PATH=/usr/local/bin/bemenu-app/ BEMENU_RENDERERS=/usr/local/bin/bemenu-app/ /usr/local/bin/bemenu-app/_bemenu -i --fb "#282828" --ff "#ebdbb2" --nb "#282828" --nf "#ebdbb2" --tb "#282828" --hb "#282828" --tf "#fb4934" --hf "#fabd2f" --nf "#ebdbb2" --af "#ebdbb2" --ab "#282828" --hp 10 -fn "Fantasque Sans Mono Bold:size=13" "${@}"
	echo -e "${input}" | LD_LIBRARY_PATH=/usr/local/bin/bemenu-app/ BEMENU_RENDERERS=/usr/local/bin/bemenu-app/ /usr/local/bin/bemenu-app/_bemenu -i --fb "#0A0A0A" --ff "#DEEEED" --nb "#0A0A0A" --nf "#DEEEED" --tb "#0A0A0A" --hb "#0A0A0A" --tf "#D70000" --hf "#ffAA88" --nf "#DEEEED" --af "#DEEEED" --ab "#0A0A0A" --hp 10 -fn "Fantasque Sans Mono Bold:size=13" "${@}"
else
	# echo "${input}" | LD_LIBRARY_PATH=/usr/local/bin/bemenu-app BEMENU_RENDERERS=/usr/local/bin/bemenu-app /usr/local/bin/bemenu-app/_bemenu -i --fb "#282828" --ff "#ebdbb2" --nb "#282828" --nf "#ebdbb2" --tb "#282828" --hb "#282828" --tf "#fb4934" --hf "#fabd2f" --nf "#ebdbb2" --af "#ebdbb2" --ab "#282828" --hp 10 -fn "Fantasque Sans Mono Bold:size=13" "${@}"
	echo "${input}" | LD_LIBRARY_PATH=/usr/local/bin/bemenu-app BEMENU_RENDERERS=/usr/local/bin/bemenu-app /usr/local/bin/bemenu-app/_bemenu -i --fb "#0A0A0A" --ff "#DEEEED" --nb "#0A0A0A" --nf "#DEEEED" --tb "#0A0A0A" --hb "#0A0A0A" --tf "#D70000" --hf "#ffAA88" --nf "#DEEEED" --af "#DEEEED" --ab "#0A0A0A" --hp 10 -fn "Fantasque Sans Mono Bold:size=13" "${@}"
fi
EOF
	chmod +x ./bemenu
}

createBemenuRun() {
	# Create bemenu-run
	touch bemenu-run
	cat <<'EOF' >>./bemenu-run
#!/usr/bin/env bash

# LD_LIBRARY_PATH=/usr/local/bin/bemenu-app/ BEMENU_RENDERERS=/usr/local/bin/bemenu-app/ /usr/local/bin/bemenu-app/_bemenu-run -i --fb "#282828" --ff "#ebdbb2" --nb "#282828" --nf "#ebdbb2" --tb "#282828" --hb "#282828" --tf "#fb4934" --hf "#fabd2f" --nf "#ebdbb2" --af "#ebdbb2" --ab "#282828" --hp 10 -fn "Fantasque Sans Mono Bold:size=13" "${@}"
LD_LIBRARY_PATH=/usr/local/bin/bemenu-app/ BEMENU_RENDERERS=/usr/local/bin/bemenu-app/ /usr/local/bin/bemenu-app/_bemenu-run -i --fb "#0A0A0A" --ff "#DEEEED" --nb "#0A0A0A" --nf "#DEEEED" --tb "#0A0A0A" --hb "#0A0A0A" --tf "#D70000" --hf "#ffAA88" --nf "#DEEEED" --af "#DEEEED" --ab "#0A0A0A" --hp 10 -fn "Fantasque Sans Mono Bold:size=13" "${@}"
EOF
	chmod +x ./bemenu-run
}

createScripts() {
	# Rename
	mv ./bemenu ./_bemenu
	mv ./bemenu-run ./_bemenu-run

	createBemenu
	createBemenuRun
}

fetch() {
	# Delete everything except current script
	ls | grep -xv "help.sh" | xargs rm -rf

	# Fetch new updates
	git clone https://github.com/Cloudef/bemenu
	cd bemenu
	rm -rf .git .github preview.svg workflows/
	cd ..
	find ./bemenu -mindepth 1 -exec mv -t . {} +
	rm -rf bemenu
	rm -rf .git
}

build() {
	if [[ "$1" = "x11" || "$1" = "wayland" || "$1" = "curses" ]]; then
		fetch
		make clients "$1"
		createScripts
	fi
}

if [[ "$1" = "x11" ]]; then
	build "$1"
elif [[ "$1" = "wayland" ]]; then
	build "$1"
elif [[ "$1" = "curses" ]]; then
	build "$1"
fi
