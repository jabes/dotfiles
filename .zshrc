export ZSH="$HOME/.oh-my-zsh"
export EDITOR="subl"
export VISUAL="vim"

ZSH_THEME="robbyrussell"

# https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
plugins=(
    git
    zsh-autosuggestions
)

source "$ZSH/oh-my-zsh.sh"

alias ll="LC_COLLATE=C ls -lhA --color"
alias ls="ls -CF"
alias ..="cd .."
alias open="xdg-open"
alias subl="subl3"
alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"

# https://stackoverflow.com/a/16957078
function search-file-contents() {
    local FILE_PATH=$1
    local SEARCH_PATTERN=$2
    grep -rnw "$FILE_PATH" -e "$SEARCH_PATTERN"
}

# https://stackoverflow.com/a/3211670
function batch-photo-rename() {
    local INDEX=0
    local IN_PATH=""
    local OUT_PATH=""
    local DEFAULT_DIR="."
    local DIRECTORY=${1:-$DEFAULT_DIR}
    local IMAGE_PREFIX="IMG_"
    local IMAGE_EXTENSION=".jpg"
    ls -t \
       --almost-all \
       --reverse \
       --format=single-column \
       --file-type \
       "$DIRECTORY" | while read FILENAME
    do
		let INDEX=INDEX+1
		IN_PATH=$(realpath "$DIRECTORY/$FILENAME")
        OUT_PATH=$(printf "%s/%s%04d%s" "$DIRECTORY" "$IMAGE_PREFIX" "$INDEX" "$IMAGE_EXTENSION")
        OUT_PATH=$(realpath $OUT_PATH)
		if [[ "$OUT_PATH" == "$IN_PATH" ]]; then
	        echo "Fail: $OUT_PATH and $IN_PATH are the same."
	        continue
        elif [[ -f "$OUT_PATH" ]]; then
			echo "Fail: $OUT_PATH already exists."
	        continue
        fi
        mv -i -- "$IN_PATH" "$OUT_PATH"
        echo "Success: $IN_PATH -> $OUT_PATH"
    done
}

# Arguments:
# 1. Path to the directory where the images can be found
# 2. Desired frame scale for the output video (ex: .5 is half the original size)
# 3. Desired frame rate per second for the output video
# Example Usage:
# make-timelapse-video ~/Timelapse .25 60
function make-timelapse-video() {
    local DIRECTORY=${1:-.}
    local FRAME_SCALE=${2:-1}
	local FRAME_RATE=${3:-30}
	local INPUT_PATTERN="$DIRECTORY/IMG_%04d.jpg"
	local FIRST_IMAGE=$(printf "$INPUT_PATTERN" 1)
	local IN_WIDTH=$(exiv2 -g Exif.Photo.PixelXDimension -Pv "$FIRST_IMAGE")
	local IN_HEIGHT=$(exiv2 -g Exif.Photo.PixelYDimension -Pv "$FIRST_IMAGE")
	local OUT_WIDTH=$(($IN_WIDTH * $FRAME_SCALE))
	local OUT_HEIGHT=$(($IN_HEIGHT * $FRAME_SCALE))
	local FRAME_SIZE=$(printf "%d%s%d" "$OUT_WIDTH" "x" "$OUT_HEIGHT")
	local VIDEO_ENCODER="libx264"
    local PRESET="slow"
	local OUTPUT_PATH=$(printf "%s/timelapse_%sfps_%dx%d.mkv" "$DIRECTORY" "$FRAME_RATE" "$OUT_WIDTH" "$OUT_HEIGHT")
	ffmpeg -r $FRAME_RATE \
	       -i $INPUT_PATTERN \
	       -s $FRAME_SIZE \
	       -vcodec $VIDEO_ENCODER \
	       -preset $PRESET \
	       $OUTPUT_PATH
}

function update-packages() {
	sudo pacman -Syu
    yay -Syu
}

function remove-unused-packages() {
    local PACKAGES=$(pacman -Qtdq)
	if [ -z "$PACKAGES" ]; then
		echo "No orphan packages found."
		return
	fi
    sudo pacman -Rns "$PACKAGES"
}

function clear-yogurt-cache() {
    echo "Clearing cached AUR packages..."
    local CACHE_PATH="$HOME/.cache/yay"
    local SIZE=$(du -hs $CACHE_PATH | cut -f1)
    local TOTAL=$(ls -1q $CACHE_PATH | wc -l)
    rm -rf $CACHE_PATH
    mkdir -p $CACHE_PATH
    echo "$TOTAL cached files deleted."
    echo "$SIZE of disk space saved."
    echo "Done."
}

function clear-package-cache() {
    sudo paccache -rk0
	clear-yogurt-cache
}
