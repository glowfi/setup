#!/usr/bin/env bash

### Dependencies
# gum
# yt-dlp
# ffmpeg
# GNU Coreutils
# mpv (optional)


# Trim a audio file's time
trad() {

    filelocation

    cutChoice
    finalname=$(basename "$filename" | sed 's/\.[^.]*$//' )

    curr=("$PWD")
    cd $(dirname "$filename")
    ffmpeg -i "$filename" -ss "$start" -to "$end" -f mp3 -ab 192000 -vn "trad-$finalname.mp3"
    cd "$curr"
}

# Trim a video files's time
trvi(){

    filelocation

    cutChoice
    finalname=$(basename "$filename" | sed 's/\.[^.]*$//' )

    curr=("$PWD")
    cd $(dirname "$filename")
    ffmpeg -i "$filename" -vcodec copy -acodec copy -ss "$start" -to "$end" "trvi-$finalname.mp4"
    cd "$curr"
}

# Merge two audio files
mado(){

    file1="$HOME/$(gum file -a $HOME)"
    file2="$HOME/$(gum file -a $HOME)"

    curr=("$PWD")
    cd $(dirname "$file1")
    ffmpeg -i "$file1" -i "$file2" -filter_complex '[0:0][1:0]concat=n=2:v=0:a=1[out]' -map '[out]' "merged.mp3"
    cd "$curr"
}

# Increase Volume of an audio file
incv(){

    filelocation

    factor=$(gum input --placeholder "Enter a reasonable number how much times the volume should be increased (0-10)")

    ffmpeg -i "$filename" -filter:a "volume="$factor"" "incv-$filename_without_extension.mp3"
}

# Convert Video to Gif
video2gif(){

    methods=$(echo -e "1.Pure FFMPEG\n2.Custom Library")
    method=$(echo "$methods"| gum filter --placeholder "Choose Conversion Method"|awk -F"." '{print $1}')
    filelocation
    cutChoice

    if [[ "$method" = "1" ]]; then
        quality=$(gum input --placeholder "Enter quality of gif to render (can be 480p 640p 1080p) Higher Quality will make gif size larger!")
        fps=$(gum input --placeholder "Enter FPS or framerate for the gif")
        ffmpeg -y -ss "$start" -t "$end" -i "$filename" -vf "fps=$fps,scale=$quality:-1:flags=lanczos,palettegen" palette.png
        ffmpeg -ss "$start" -t "$end" -i "$filename" -i palette.png -filter_complex "fps=$fps,scale=$quality:-1:flags=lanczos[x];[x][1:v]paletteuse" "$filename_without_extension.gif"
        rm palette.png
    else
        ffmpeg -i "$filename" -vcodec copy -acodec copy -ss "$start" -to "$end" temp.mp4
        ezgif -i temp.mp4 -z 3
        rm -rf temp.mp4
    fi
}

# Download Youtube Video
ytvid(){

    link=$(gum input --placeholder "Enter the youtube video link")
    title=$(yt-dlp --skip-download --get-title --no-warnings "$link" | sed 2d |sed 's/[^a-zA-Z0-9 ]//g'|xargs)

    echo "Fetching Download Quality Available..."

    # Get video quality and download
    yt-dlp -F "$link" | sed '1,5d' | grep "video only" | gum filter --placeholder "Choose Quality for video:" | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --output "$title.%(ext)s" --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$link"
}

# Download Youtube Audio
ytaud(){

    link=$(gum input --placeholder "Enter the youtube video link")
    title=$(yt-dlp --skip-download --get-title --no-warnings "$link" | sed 2d |sed 's/[^a-zA-Z0-9 ]//g'|xargs)

    echo "Fetching Download Quality Available..."

    # Get audio quality and download
    yt-dlp -F "$link" | sed '1,5d' | grep "audio only" | gum filter --placeholder "Choose Quality for audio:" | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --output "$title.%(ext)s" --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$link"
}

# Download Youtube video with custom video and audio Quality
ytcustomAudioVideo(){

    link=$(gum input --placeholder "Enter the youtube video link")
    title=$(yt-dlp --skip-download --get-title --no-warnings "$link" | sed 2d |sed 's/[^a-zA-Z0-9 ]//g'|xargs)

    echo "Fetching Video Download Quality Available..."
    # Get video quality
    yt-dlp -F "$link" | sed '1,5d' | grep "video only" | gum filter --placeholder "Choose Quality for video:" | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --output "my_video_fetched.%(ext)s" --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$link"

    echo "Fetching Audio Download Quality Available..."
    # Get audio quality
    yt-dlp -F "$link" | sed '1,5d' | grep "audio only" | gum filter --placeholder "Choose Quality for audio:" | awk '{print $1}' | xargs -t -I {} yt-dlp -f {} --output "my_audio_fetched.%(ext)s" --external-downloader aria2c --external-downloader-args "-j 16 -x 16 -s 16 -k 1M" "$link"

    # Merge
    vid=$(find $HOME \( ! -regex '.*/\..*' \) -type f -name "my_video_fetched.*")
    aud=$(find $HOME \( ! -regex '.*/\..*' \) -type f -name "my_audio_fetched.*")
    echo "$vid"
    echo "$aud"
    echo "$title"
    ffmpeg -i "$vid" -i "$aud" -map 0:0 -map 1:0 -c:v copy -c:a aac -b:a 256k -shortest "$title".mp4
    rm -rf "$vid"
    rm -rf "$aud"
}

extractAudio(){

    filelocation
    finalname=$(basename "$filename" | sed 's/\.[^.]*$//' )

    curr=("$PWD")
    cd $(dirname "$filename")
    ffmpeg -i "$filename" -vn -q:a 0 -map a "exa-$finalname.mp3"
    cd "$curr"
}

extractVideo(){

    filelocation
    finalname=$(basename "$filename" | sed 's/\.[^.]*$//' )

    curr=("$PWD")
    cd $(dirname "$filename")
    ffmpeg -i "$filename" -an -vcodec copy "exv-$finalname.mp4"
    cd "$curr"
}

convertFormat(){

    filelocation
    finalname=$(basename "$filename" | sed 's/\.[^.]*$//' )
    format=$(gum input --placeholder "Enter format to convert the file")

    curr=("$PWD")
    cd $(dirname "$filename")
    ffmpeg -i "$filename" "$finalname.$format"
    cd "$curr"
}

# Location of file
filelocation(){
    filename="$HOME/$(gum file -a $HOME)"
    filename_without_extension="$(echo "$filename" | sed 's/\.[^.]*$//')"
}

cutChoice(){
    cut=$(echo -e "1.Precise Cut\n2.Manual Cut"| gum filter --placeholder "Choose Cut Type:"|awk -F"." '{print $1}')

    if [[ "$cut" = "1" ]]; then
        preciseCut
    else
        manualCut
    fi
}

preciseCut(){

    start=$(mpv "$filename"|& tee -a /dev/stderr | grep -o ..:..:.. | tail -n 2 | head -n 1)
    end=$(mpv "$filename"|& tee -a /dev/stderr | grep -o ..:..:.. | tail -n 2 | head -n 1)

}

manualCut(){
    start=$( gum input --placeholder "Enter Start Time of the video (HH:MM:SS) format")
    end=$(gum input --placeholder "Enter End Time of the video (HH:MM:SS) format")
}


# Default Constants
filename=""
filename_without_extension=""
start=""
end=""

# CD To Home Directory
cd

# Choose Operation to Perform
operation=$(echo -e "1. Trim Audio File
2. Trim Video File
3. Merge 2 Audio Files
4. Increase Volume of a Audio file by a factor
5. Convert Video to gif
6. Extract Audio Only
7. Extract Video Only
8. Convert to format
9. Download a Youtube Video
10.Download a Youtube Audio
11.Download Youtube Video with custom audio and video quality")

# Extract Choice
choice=$(echo "$operation"| gum filter --placeholder "Choose Operation to Perform" | awk -F"." '{print $1}'| xargs)

if [[ "$choice" = "1" ]]; then
    trad
elif [[ "$choice" = "2" ]]; then
    trvi
elif [[ "$choice" = "3" ]]; then
    mado
elif [[ "$choice" = "4" ]]; then
    incv
elif [[ "$choice" = "5" ]]; then
    video2gif
elif [[ "$choice" = "6" ]]; then
    extractAudio
elif [[ "$choice" = "7" ]]; then
    extractVideo
elif [[ "$choice" = "8" ]]; then
    convertFormat
elif [[ "$choice" = "9" ]]; then
    ytvid
elif [[ "$choice" = "10" ]]; then
    ytaud
elif [[ "$choice" = "11" ]]; then
    ytcustomAudioVideo
fi
