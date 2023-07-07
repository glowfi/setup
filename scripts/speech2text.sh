#!/usr/bin/env sh

speech2textdefinite(){
    # Take mic input
    echo -e "${GREEN}Listening ...${NORMAL}"
    ffmpeg -y -f alsa -i default -acodec pcm_s16le -ac 1 -ar 44100 -t 5 -f wav $HOME/.cache/speech.wav

    # Save speech and convert it into text
    clear
    echo -e "${YELLOW}Transcribing Speech to Text ...${NORMAL}"
    saveCWD=$(echo "$pwd")
    cd $MODEL_PATH

    # Cleanup Old Files
    echo "Cleaning old files... Ignore any not found messages below"
    find . ! -name . -prune -type d -exec rm -rf {} +
    rm *.vtt *.txt *.tsv *.json *.srt


    # Transcribe
    whisper $HOME/.cache/speech.wav --model_dir "$MODEL_PATH" --task transcribe
    text=$(cat $MODEL_PATH/speech.txt)
    epoch=$(date +%s)
    mkdir $epoch
    mkdir $HOME/Documents/transcribed
    mv *.vtt *.txt *.tsv *.json *.srt $epoch
    mv $epoch $HOME/Documents/transcribed
    cd "$saveCWD"

    # CD into the output directory
    clear
    echo -e "${GREEN}Output${NORMAL}"
    cd $HOME/Documents/transcribed/$epoch
    ls

    # Print the text
    clear
    echo -e "${GREEN}$text${NORMAL}\n\n"
    echo -e "${RED} Files saved at : ${HOME}/Documents/transcribed/$epoch ${NORMAL}"
}

speech2textinfinite(){
    # Take mic input
    echo -e "${GREEN}Listening ...${NORMAL}"
    ffmpeg -y -f alsa -i default -acodec pcm_s16le -ac 1 -ar 44100 -f wav $HOME/.cache/speech.wav

    # Save speech and convert it into text
    clear
    echo -e "${YELLOW}Transcribing Speech to Text ...${NORMAL}"
    saveCWD=$(echo "$pwd")
    cd $MODEL_PATH

    # Cleanup Old Files
    echo "Cleaning old files... Ignore any not found messages below"
    find . ! -name . -prune -type d -exec rm -rf {} +
    rm *.vtt *.txt *.tsv *.json *.srt


    # Transcribe
    whisper $HOME/.cache/speech.wav --model_dir "$MODEL_PATH" --task transcribe
    text=$(cat $MODEL_PATH/speech.txt)
    epoch=$(date +%s)
    mkdir $epoch
    mkdir $HOME/Documents/transcribed
    mv *.vtt *.txt *.tsv *.json *.srt $epoch
    mv $epoch $HOME/Documents/transcribed
    cd "$saveCWD"

    # CD into the output directory
    clear
    echo -e "${GREEN}Output${NORMAL}"
    cd $HOME/Documents/transcribed/$epoch
    ls

    # Print the text
    clear
    echo -e "${GREEN}$text${NORMAL}\n\n"
    echo -e "${RED} Files saved at : ${HOME}/Documents/transcribed/$epoch ${NORMAL}"

}

speech2textfile(){

    # Input File
    filelocation

    # Save speech and convert it into text
    clear
    echo -e "${YELLOW}Transcribing Speech to Text ...${NORMAL}"

    # Save PWD
    saveCWD=$(echo "$pwd")
    cd $MODEL_PATH

    # Cleanup Old Files
    echo "Cleaning old files... Ignore any not found messages below"
    find . ! -name . -prune -type d -exec rm -rf {} +
    rm *.vtt *.txt *.tsv *.json *.srt

    # Transcribe the given file
    whisper "$filename" --model_dir "$MODEL_PATH" --task transcribe
    epoch=$(date +%s)
    mkdir $epoch
    mkdir $HOME/Documents/transcribed
    mv *.vtt *.txt *.tsv *.json *.srt $epoch
    mv $epoch $HOME/Documents/transcribed
    cd "$saveCWD"

    # CD into the output directory
    clear
    echo -e "${GREEN}Output${NORMAL}"
    cd $HOME/Documents/transcribed/$epoch
    ls

    echo -e "${RED} Files saved at : ${HOME}/Documents/transcribed/$epoch ${NORMAL}"

}

speech2textfilelang(){

    # Input File
    filelocation

    # Input Language
    language=$(echo "$lang" | tr "," "\n" | gum filter --placeholder "Choose Input File Language :"|xargs)

    # Ask for Translation or native
    outputlang=$(echo -e "1.Native\n2.Translated to English" | gum filter --placeholder "Choose Output File Language :"|xargs|awk -F"." '{print $1}')


    # Save speech and convert it into text
    clear
    echo -e "${YELLOW}Transcribing Speech to Text ...${NORMAL}"

    # Save PWD
    saveCWD=$(echo "$pwd")
    cd $MODEL_PATH

    # Cleanup Old Files
    echo "Cleaning old files... Ignore any not found messages below"
    find . ! -name . -prune -type d -exec rm -rf {} +
    rm *.vtt *.txt *.tsv *.json *.srt

    # Transcribe the given file
    if [[ "$outputlang" = "1" ]]; then
        whisper "$filename" --model_dir "$MODEL_PATH" --language "${language}"
    else
        whisper "$filename" --model_dir "$MODEL_PATH" --language "${language}" --task translate
    fi
    epoch=$(date +%s)
    mkdir $epoch
    mkdir $HOME/Documents/transcribed
    mv *.vtt *.txt *.tsv *.json *.srt $epoch
    mv $epoch $HOME/Documents/transcribed
    cd "$saveCWD"

    # CD into the output directory
    clear
    echo -e "${GREEN}Output${NORMAL}"
    cd $HOME/Documents/transcribed/$epoch
    ls

    echo -e "${RED} Files saved at : ${HOME}/Documents/transcribed/$epoch ${NORMAL}"

}


# Location of file
filelocation(){
    filename="$HOME/$(gum file -a $HOME)"
    filename_without_extension="$(echo "$filename" | sed 's/\.[^.]*$//')"
}

# Download Model
downloadModel(){
    modelType=$(echo -e "1.tiny.en\n2.tiny\n3.base.en\n4.base\n5.small.en\n6.small\n7.medium.en\n8.medium\n9.large" |gum filter --placeholder "Choose Model to Download"|awk -F"." '{print $2}'|xargs)

    python - <<END
import sys
from whisper import _download, _MODELS

models = ["tiny.en", "tiny", "base.en", "base", "small.en", "small", "medium.en", "medium", "large"]

for model in models:
    _download(_MODELS["$modelType"], "$MODEL_PATH", False)
END
}

MODEL_PATH="$HOME/.local/share/openai-whispermodel"
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NORMAL='\033[0m'
filename=""
filename_without_extension=""
lang="Afrikaans,Albanian,Amharic,Arabic,Armenian,Assamese,Azerbaijani,Bashkir,Basque,Belarusian,Bengali,Bosnian,Breton,Bulgarian,Burmese,Castilian,Catalan,Chinese,Croatian,Czech,Danish,Dutch,English,Estonian,Faroese,Finnish,Flemish,French,Galician,Georgian,German,Greek,Gujarati,Haitian,Haitian Creole,Hausa,Hawaiian,Hebrew,Hindi,Hungarian,Icelandic,Indonesian,Italian,Japanese,Javanese,Kannada,Kazakh,Khmer,Korean,Lao,Latin,Latvian,Letzeburgesch,Lingala,Lithuanian,Luxembourgish,Macedonian,Malagasy,Malay,Malayalam,Maltese,Maori,Marathi,Moldavian,Moldovan,Mongolian,Myanmar,Nepali,Norwegian,Nynorsk,Occitan,Panjabi,Pashto,Persian,Polish,Portuguese,Punjabi,Pushto,Romanian,Russian,Sanskrit,Serbian,Shona,Sindhi,Sinhala,Sinhalese,Slovak,Slovenian,Somali,Spanish,Sundanese,Swahili,Swedish,Tagalog,Tajik,Tamil,Tatar,Telugu,Thai,Tibetan,Turkish,Turkmen,Ukrainian,Urdu,Uzbek,Valencian,Vietnamese,Welsh,Yiddish,Yoruba"

# CD To Home Directory
cd


if [ -d "$MODEL_PATH" ]; then
    # Choose Operation to Perform
    operation=$(echo -e "1. Speech 2 Text (5 seconds)
2.Speech 2 Text (Press q to stop recording)
3.Speech 2 Text from a file (Autodetect input file language)
4.Speech 2 Text from a file (Mention the language of input file)
5.Download more model
    ")

    # Extract Choice
    choice=$(echo "$operation"| gum filter --placeholder "Choose Operation to Perform" | awk -F"." '{print $1}'| xargs)


    if [[ "$choice" = "1" ]]; then
        speech2textdefinite
    elif [[ "$choice" = "2" ]]; then
        speech2textinfinite
    elif [[ "$choice" = "3" ]]; then
        speech2textfile
    elif [[ "$choice" = "4" ]]; then
        speech2textfilelang
    elif [[ "$choice" = "5" ]]; then
        downloadModel
    fi

else
    # Install Dependencies for the first time
    echo -e "${YELLOW}Installing Dependencies ...${NORMAL}"
    rm -rf "$MODEL_PATH"
    pip install git+https://github.com/openai/whisper.git
    mkdir -p "$MODEL_PATH"
    clear
    echo -e "${YELLOW}Downloading Model ...${NORMAL}"
    downloadModel
    clear
    echo -e "${GREEN}Model Downloaded! Run the script Again to convert speech to text!${NORMAL}"
fi
