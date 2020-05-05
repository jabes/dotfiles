#!/usr/bin/env bash
# SC2059: Don't use variables in the printf format string.
# shellcheck disable=SC2059

# Arguments:
# 1. Path to the directory where the images can be found
# 2. Desired frame scale for the output video (ex: .5 is half the original size)
# 3. Desired frame rate per second for the output video
# Example Usage:
# make-timelapse-video ~/Timelapse .25 60 18 slow
function make-timelapse-video() {
  # Input parameters
  local INPUT_DIRECTORY=${1:-.}
  local FRAME_SCALE=${2:-1}
  local FRAME_RATE=${3:-30}
  local ENCODE_CRF=${4:-10}        # 0 is lossless and 18 is visually lossless
  local ENCODE_PRESET=${5:-slower} # medium is default compression quality

  # Define local vars
  local ENCODE_CODEC
  local INPUT_PATTERN
  local FIRST_IMAGE
  local IN_WIDTH
  local IN_HEIGHT
  local OUT_WIDTH
  local OUT_HEIGHT
  local FRAME_SIZE
  local OUTPUT_DIRECTORY
  local OUTPUT_PATH

  # Calculate encoding values
  ENCODE_CODEC="libx264"
  INPUT_PATTERN="DSC_%04d.JPG"
  FIRST_IMAGE=$(printf "$INPUT_PATTERN" 1)
  IN_WIDTH=$(exiv2 -g Exif.Photo.PixelXDimension -Pv "$INPUT_DIRECTORY/$FIRST_IMAGE")
  IN_HEIGHT=$(exiv2 -g Exif.Photo.PixelYDimension -Pv "$INPUT_DIRECTORY/$FIRST_IMAGE")
  OUT_WIDTH=$((IN_WIDTH * FRAME_SCALE))
  OUT_HEIGHT=$((IN_HEIGHT * FRAME_SCALE))
  FRAME_SIZE=$(printf "%dx%d" "$OUT_WIDTH" "$OUT_HEIGHT")
  OUTPUT_DIRECTORY="$INPUT_DIRECTORY/rendered"
  OUTPUT_PATH=$(printf "%s/timelapse_%sfps_%s_%scrf_%s.mp4" "$OUTPUT_DIRECTORY" "$FRAME_RATE" "$FRAME_SIZE" "$ENCODE_CRF" "$ENCODE_PRESET")

  # Create output directory
  echo "Output directory: $OUTPUT_DIRECTORY"
  mkdir -p "$OUTPUT_DIRECTORY"

  # https://trac.ffmpeg.org/wiki/Encode/H.264
  ffmpeg \
    -i "$INPUT_DIRECTORY/$INPUT_PATTERN" \
    -r "$FRAME_RATE" \
    -s "$FRAME_SIZE" \
    -vcodec "$ENCODE_CODEC" \
    -preset "$ENCODE_PRESET" \
    -crf "$ENCODE_CRF" \
    "$OUTPUT_PATH"
}
