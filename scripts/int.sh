#!/bin/bash

choosen=$(printf "1.Image search in Google\n2.Extract Text From Image\n3.Take screenshot and search image in Google\n4.Extract Text From Image Multi Language\n5.Extract Text From File\n6.Extract Text From File MultiLanguage" | dmenu -i -p "Choose:")
choosen=$(echo "$choosen" | awk -F"." '{print $1}')

#### Functions

## Image Search in Google
callreverseSearch() {
	image=$(fd --type f . | dmenu -l 30 -i -p "Choose Image:")
	searchUrl="https://www.google.com/searchbyimage/upload"

	if [[ "$image" != "" ]]; then
		link=$(curl -i -F sch=sch -F encoded_image=@"$image" "$searchUrl" | grep -oP 'location: \K.*')
		notify-send "Done! Showing results in Browser ..."
		xdg-open "$link"
	fi
}

## Take screenshot and search image in Google
callreverseSearchV2() {
	print_date() {
		date "+%e %B %Y %-I:%M:%S.%3N" | tr " " "-"
	}

	SCREENSHOTDIR="${HOME}/Pictures/ScreenShots"
	mkdir -p "${SCREENSHOTDIR}"
	SCREENSHOTNAME="${SCREENSHOTDIR}/$(print_date).png"
	searchUrl="https://www.google.com/searchbyimage/upload"

	killall unclutter
	import "${SCREENSHOTNAME}"
	setsid unclutter &

	if [[ "$SCREENSHOTNAME" != "" ]]; then
		link=$(curl -i -F sch=sch -F encoded_image=@"$SCREENSHOTNAME" "$searchUrl" | grep -oP 'location: \K.*')
		notify-send "Done! Showing results in Browser ..."
		xdg-open "$link"
	fi
}

## Extract Text From Image By Taking screenshot
callTesseract() {
	print_date() {
		date "+%e %B %Y %-I:%M:%S.%3N" | tr " " "-"
	}

	SCREENSHOTDIR="${HOME}/Pictures/ScreenShots"
	mkdir -p "${SCREENSHOTDIR}"
	SCREENSHOTNAME="${SCREENSHOTDIR}/$(print_date).png"

	killall unclutter
	import "${SCREENSHOTNAME}"
	setsid unclutter &

	extractedText=$(tesseract "$SCREENSHOTNAME" -)
	if [[ "$extractedText" != "" ]]; then
		echo "$extractedText" | xclip -sel c
		notify-send "Extracted Text copied to clipboard!"
	fi
}

## Extract Text By Taking screenshot
multiLangTesseract() {
	print_date() {
		date "+%e %B %Y %-I:%M:%S.%3N" | tr " " "-"
	}

	SCREENSHOTDIR="${HOME}/Pictures/ScreenShots"
	mkdir -p "${SCREENSHOTDIR}"
	SCREENSHOTNAME="${SCREENSHOTDIR}/$(print_date).png"

	killall unclutter
	import "${SCREENSHOTNAME}"
	setsid unclutter &

	getLang=$(printf "afr Afrikaans\namh Amharic\nara Arabic\nasm Assamese\naze Azerbaijani\naze_cyrl Azerbaijani\nbel Belarusian\nben Bengali\nbod Tibetan\nbos Bosnian\nbre Breton\nbul Bulgarian\ncat Catalan\nceb Cebuano\nces Czech\nchi_sim Chinese\nchi_tra Chinese\nchr Cherokee\ncos Corsican\ncym Welsh\ndan Danish\ndan_frak Danish\ndeu German\ndeu_frak German\ndzo Dzongkha\nell Greek\neng English\nenm English\nepo Esperanto\nequ Math\nest Estonian\neus Basque\nfao Faroese\nfas Persian\nfil Filipino\nfin Finnish\nfra French\nfrk German\nfrm French\nfry Western\ngla Scottish\ngle Irish\nglg Galician\ngrc Greek\nguj Gujarati\nhat Haitian\nheb Hebrew\nhin Hindi\nhrv Croatian\nhun Hungarian\nhye Armenian\niku Inuktitut\nind Indonesian\nisl Icelandic\nita Italian\nita_old Italian\njav Javanese\njpn Japanese\nkan Kannada\nkat Georgian\nkat_old Georgian\nkaz Kazakh\nkhm Central\nkir Kirghiz\nkmr Kurmanji\nkor Korean\nkor_vert Korean\nkur Kurdish\nlao Lao\nlat Latin\nlav Latvian\nlit Lithuanian\nltz Luxembourgish\nmal Malayalam\nmar Marathi\nmkd Macedonian\nmlt Maltese\nmon Mongolian\nmri Maori\nmsa Malay\nmya Burmese\nnep Nepali\nnld Dutch\nnor Norwegian\noci Occitan\nori Oriya\nosd Orientation\npan Panjabi\npol Polish\npor Portuguese\npus Pushto\nque Quechua\nron Romanian\nrus Russian\nsan Sanskrit\nsin Sinhala\nslk Slovak\nslk_frak Slovak\nslv Slovenian\nsnd Sindhi\nspa Spanish\nspa_old Spanish\nsqi Albanian\nsrp Serbian\nsrp_latn Serbian\nsun Sundanese\nswa Swahili\nswe Swedish\nsyr Syriac\ntam Tamil\ntat Tatar\ntel Telugu\ntgk Tajik\ntgl Tagalog\ntha Thai\ntir Tigrinya\nton Tonga\ntur Turkish\nuig Uighur\nukr Ukrainian\nurd Urdu\nuzb Uzbek\nuzb_cyrl Uzbek\nvie Vietnamese\nyid Yiddish\nyor Yoruba" | dmenu -i -l 10 -p "Choose Language:" | awk -F" " '{print $1}')
	extractedText=$(tesseract -l "$getLang" "$SCREENSHOTNAME" -)
	if [[ "$extractedText" != "" ]]; then
		echo "$extractedText" | xclip -sel c
		notify-send "Extracted Text copied to clipboard!"
	fi
}

## Extract Text From File
callTesseractFile() {
	getFile=$(fd --exclude "$HOME/go" --type file --print0 --max-depth 3 --full-path "$HOME" | xargs -0 -I{} stat --format "%Y %n" "{}" | sort -rn | dmenu -i -l 20 | awk -F" " '{print $2}')
	fileLocation=$(realpath "$getFile")

	if [[ "$getFile" != "" ]]; then
		extractedText=$(tesseract "$fileLocation" -)
		if [[ "$extractedText" != "" ]]; then
			echo "$extractedText" | xclip -sel c
			notify-send "Extracted Text copied to clipboard!"
		fi
	fi
}

## Extract Text From File (Multi Language)
callTesseractFileMulti() {
	getFile=$(fd --exclude "$HOME/go" --type file --print0 --max-depth 3 --full-path "$HOME" | xargs -0 -I{} stat --format "%Y %n" "{}" | sort -rn | dmenu -i -l 20 | awk -F" " '{print $2}')
	fileLocation=$(realpath "$getFile")

	if [[ "$getFile" != "" ]]; then
		getLang=$(printf "afr Afrikaans\namh Amharic\nara Arabic\nasm Assamese\naze Azerbaijani\naze_cyrl Azerbaijani\nbel Belarusian\nben Bengali\nbod Tibetan\nbos Bosnian\nbre Breton\nbul Bulgarian\ncat Catalan\nceb Cebuano\nces Czech\nchi_sim Chinese\nchi_tra Chinese\nchr Cherokee\ncos Corsican\ncym Welsh\ndan Danish\ndan_frak Danish\ndeu German\ndeu_frak German\ndzo Dzongkha\nell Greek\neng English\nenm English\nepo Esperanto\nequ Math\nest Estonian\neus Basque\nfao Faroese\nfas Persian\nfil Filipino\nfin Finnish\nfra French\nfrk German\nfrm French\nfry Western\ngla Scottish\ngle Irish\nglg Galician\ngrc Greek\nguj Gujarati\nhat Haitian\nheb Hebrew\nhin Hindi\nhrv Croatian\nhun Hungarian\nhye Armenian\niku Inuktitut\nind Indonesian\nisl Icelandic\nita Italian\nita_old Italian\njav Javanese\njpn Japanese\nkan Kannada\nkat Georgian\nkat_old Georgian\nkaz Kazakh\nkhm Central\nkir Kirghiz\nkmr Kurmanji\nkor Korean\nkor_vert Korean\nkur Kurdish\nlao Lao\nlat Latin\nlav Latvian\nlit Lithuanian\nltz Luxembourgish\nmal Malayalam\nmar Marathi\nmkd Macedonian\nmlt Maltese\nmon Mongolian\nmri Maori\nmsa Malay\nmya Burmese\nnep Nepali\nnld Dutch\nnor Norwegian\noci Occitan\nori Oriya\nosd Orientation\npan Panjabi\npol Polish\npor Portuguese\npus Pushto\nque Quechua\nron Romanian\nrus Russian\nsan Sanskrit\nsin Sinhala\nslk Slovak\nslk_frak Slovak\nslv Slovenian\nsnd Sindhi\nspa Spanish\nspa_old Spanish\nsqi Albanian\nsrp Serbian\nsrp_latn Serbian\nsun Sundanese\nswa Swahili\nswe Swedish\nsyr Syriac\ntam Tamil\ntat Tatar\ntel Telugu\ntgk Tajik\ntgl Tagalog\ntha Thai\ntir Tigrinya\nton Tonga\ntur Turkish\nuig Uighur\nukr Ukrainian\nurd Urdu\nuzb Uzbek\nuzb_cyrl Uzbek\nvie Vietnamese\nyid Yiddish\nyor Yoruba" | dmenu -i -l 10 -p "Choose Language:" | awk -F" " '{print $1}')
		extractedText=$(tesseract -l "$getLang" "$fileLocation" -)
		if [[ "$extractedText" != "" ]]; then
			echo "$extractedText" | xclip -sel c
			notify-send "Extracted Text copied to clipboard!"
		fi
	fi
}

#### Handle Choosen
if [[ "$choosen" == "1" ]]; then
	callreverseSearch
elif
	[[ "$choosen" == "2" ]]
then
	callTesseract
elif
	[[ "$choosen" == "3" ]]
then
	callreverseSearchV2
elif
	[[ "$choosen" == "4" ]]
then
	multiLangTesseract
elif
	[[ "$choosen" == "5" ]]
then
	callTesseractFile
elif
	[[ "$choosen" == "6" ]]
then
	callTesseractFileMulti
fi
