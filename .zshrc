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
    local FILENAME=""
    local RENAMED=""
    local DEFAULT_DIR="."
    local DIRECTORY=${1:-$DEFAULT_DIR}
    local IMAGE_PREFIX="DSC_"
    local IMAGE_EXTENSION=".JPG"
    local PATTERN=($DIRECTORY/$IMAGE_PREFIX*$IMAGE_EXTENSION)
    for FILENAME in $PATTERN; do
        let INDEX=INDEX+1
        RENAMED=$(printf "%s/%s%04d%s" "$DIRECTORY" "$IMAGE_PREFIX" "$INDEX" "$IMAGE_EXTENSION")
        if [[ "$RENAMED" == "$FILENAME" ]]; then
	        echo "Fail: $RENAMED and $FILENAME are the same."
	        continue
        elif [[ -f "$RENAMED" ]]; then
        	echo "Fail: $RENAMED already exists."
	        continue
        fi
        mv -i -- "$FILENAME" "$RENAMED"
        echo "Success: $FILENAME -> $RENAMED"
    done
}

function make-timelapse-video() {
    local DEFAULT_DIR="."
    local DIRECTORY=${1:-$DEFAULT_DIR}
	local INPUT_IMAGE="$DIRECTORY/DSC_%04d.JPG"
	local FRAME_RATE=30
	local IN_WIDTH=6000
	local IN_HEIGHT=4000
	local FRAME_SCALE=0.5
	local OUT_WIDTH=$(($IN_WIDTH * $FRAME_SCALE))
	local OUT_HEIGHT=$(($IN_HEIGHT * $FRAME_SCALE))
	local FRAME_SIZE=$(printf "%d%s%d" "$OUT_WIDTH" "x" "$OUT_HEIGHT")
	local VIDEO_ENCODER="libx264"
    local PRESET="slow"
    local RAND=$(date +%s)
	local OUTPUT_PATH="$DIRECTORY/timelapse_$RAND.mkv"
	ffmpeg -r $FRAME_RATE \
	       -i $INPUT_IMAGE \
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
