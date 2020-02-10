#!/usr/bin/env bash

# Arguments:
# 1. Path to the directory where the images can be found
# 2. Desired frame scale for the output video (ex: .5 is half the original size)
# 3. Desired frame rate per second for the output video
# Example Usage:
# make-timelapse-video ~/Timelapse .25 60 18 slow
function make-timelapse-video() {
    local INPUT_DIRECTORY=${1:-.}
    local FRAME_SCALE=${2:-1}
    local FRAME_RATE=${3:-30}
    local ENCODE_CRF=${4:-10} # 0 is lossless and 18 is visually lossless
    local ENCODE_PRESET=${5:-slower} # medium is default compression quality
    local ENCODE_CODEC="libx264"
    local INPUT_PATTERN="$INPUT_DIRECTORY/DSC_%04d.JPG"
    local FIRST_IMAGE=$(printf "$INPUT_PATTERN" 1)
    local IN_WIDTH=$(exiv2 -g Exif.Photo.PixelXDimension -Pv $FIRST_IMAGE)
    local IN_HEIGHT=$(exiv2 -g Exif.Photo.PixelYDimension -Pv $FIRST_IMAGE)
    local OUT_WIDTH=$(($IN_WIDTH * $FRAME_SCALE))
    local OUT_HEIGHT=$(($IN_HEIGHT * $FRAME_SCALE))
    local FRAME_SIZE=$(printf "%dx%d" "$OUT_WIDTH" "$OUT_HEIGHT")
    local OUTPUT_DIRECTORY="$INPUT_DIRECTORY/rendered"
    local OUTPUT_PATH=$(printf "%s/timelapse_%sfps_%s_%scrf_%s.mp4" "$OUTPUT_DIRECTORY" "$FRAME_RATE" "$FRAME_SIZE" "$ENCODE_CRF" "$ENCODE_PRESET")

    mkdir -p "$OUTPUT_DIRECTORY"

    # https://trac.ffmpeg.org/wiki/Encode/H.264
    ffmpeg -r "$FRAME_RATE" \
           -i "$INPUT_PATTERN" \
           -s "$FRAME_SIZE" \
           -vcodec "$ENCODE_CODEC" \
           -preset "$ENCODE_PRESET" \
           -crf "$ENCODE_CRF" \
           "$OUTPUT_PATH"
}
