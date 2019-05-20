#!/usr/bin/env bash

function batch-photo-rename() {
    local IMAGE_DIRECTORY=${1:-$PWD}
    local IMAGE_PREFIX=${2:-DSC_}
    local IMAGE_EXTENSION=${3:-.JPG}

    if [ -z "$(ls -A $IMAGE_DIRECTORY)" ]; then
        echo "Skip: $IMAGE_DIRECTORY is empty."
        return 0
    fi

    echo "Temp: $IMAGE_DIRECTORY"

    _rename_all_images_in_path "$IMAGE_DIRECTORY" ".TEMP_" "$IMAGE_EXTENSION"

    echo "Move: $IMAGE_DIRECTORY"

    _rename_all_images_in_path "$IMAGE_DIRECTORY" "$IMAGE_PREFIX" "$IMAGE_EXTENSION"

    echo "Done: $IMAGE_DIRECTORY"
}

function _rename_all_images_in_path() {
    local INDEX=0
    local IMAGE_DIRECTORY="$1"
    local IMAGE_PREFIX="$2"
    local IMAGE_EXTENSION="$3"

    # ls -t \
    #    --almost-all \
    #    --reverse \
    #    --format=single-column \
    #    --file-type \
    #    "$IMAGE_DIRECTORY" | while read IMAGE_FILENAME

    exiftool \
        -ignoreMinorErrors \
        -table \
        -quiet \
        --composite \
        --printConv \
        -printFormat '$FileName' \
        -fileOrder DateTimeOriginal \
        "$IMAGE_DIRECTORY" | while read IMAGE_FILENAME

    do
        let INDEX=INDEX+1

        local IN_PATH="$IMAGE_DIRECTORY/$IMAGE_FILENAME"
        local OUT_PATH=$(printf "%s/%s%04d%s" "$IMAGE_DIRECTORY" "$IMAGE_PREFIX" "$INDEX" "$IMAGE_EXTENSION")
    
        if [[ ! -e "$IN_PATH" ]]; then
            echo "Skip: $IN_PATH does not exist."
            let INDEX=INDEX-1
            continue
        elif [[ -d "$IN_PATH" ]]; then
            echo "Skip: $IN_PATH is a directory, file expected."
            let INDEX=INDEX-1
            continue
        elif [[ $(file -b "$IN_PATH") != 'JPEG'* ]]; then
            echo "Skip: $IN_PATH is not a JPEG file type."
            let INDEX=INDEX-1
            continue
        elif [[ "$OUT_PATH" == "$IN_PATH" ]]; then
            echo "Skip: $OUT_PATH and $IN_PATH are the same."
            let INDEX=INDEX-1
            continue
        elif [[ -f "$OUT_PATH" ]]; then
            echo "Skip: $OUT_PATH already exists."
            let INDEX=INDEX-1
            continue
        fi

        mv -i -- "$IN_PATH" "$OUT_PATH"
        echo "Success: $IN_PATH -> $OUT_PATH"
    done
}