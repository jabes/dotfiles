#!/usr/bin/env bash
# SC2059: Don't use variables in the printf format string.
# shellcheck disable=SC2059

# Example Usage:
#    Low-res - make-timelapse-video --input=~/photos --scale=0.25 --fps=30 --crf=18 --preset=medium
# Medium-res - make-timelapse-video --input=~/photos --scale=0.50 --fps=30 --crf=16 --preset=slow
#   High-res - make-timelapse-video --input=~/photos --scale=1.00 --fps=30 --crf=14 --preset=slower
function make-timelapse-video() {
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

  # Process any provided arguments or fallback on defaults
  get-timelapse-defaults
  process-timelapse-arguments "$@"

  # Show cli usage if --help was defined
  if [[ "$SHOW_CLI_USAGE" == "yes" ]]; then
    show-timelapse-cli-usage
    return 0
  fi

  # Ensure that FFmpeg is installed
  if hash "ffmpeg" 2>/dev/null; then
    echo "FFmpeg was found."
  else
    echo >&2 "FFmpeg was not found, please install it."
    echo >&2 "brew install ffmpeg"
    return 1
  fi

  # Ensure that Exiv2 is installed
  if hash "exiv2" 2>/dev/null; then
    echo "Exiv2 was found."
  else
    echo >&2 "Exiv2 was not found, please install it."
    echo >&2 "brew install exiv2"
    return 1
  fi

  # Ensure that the input directory exists
  if [[ -d "$INPUT_DIRECTORY" ]]; then
    echo "Input directory: $(realpath "$INPUT_DIRECTORY")"
  else
    echo >&2 "The provided directory '$INPUT_DIRECTORY' does not exist."
    return 1
  fi

  INPUT_PATTERN="DSC_%04d.JPG"
  FIRST_IMAGE=$(printf "$INPUT_PATTERN" 1)
  if [[ ! -f "$FIRST_IMAGE" ]]; then
    echo >&2 "Failed to find any images in this directory."
    return 1
  fi

  TOTAL_IMAGES=$(find "$INPUT_DIRECTORY" -type f -name 'DSC_*.JPG' | wc -l)
  IMAGE_THRESHOLD=$FRAME_RATE
  if [[ "$TOTAL_IMAGES" -lt "$IMAGE_THRESHOLD" ]]; then
    echo >&2 "We did not find enough images."
    echo >&2 "A total of $TOTAL_IMAGES images have been found."
    echo >&2 "Which is less than our threshold of $IMAGE_THRESHOLD images."
    echo >&2 "You should have at least $IMAGE_THRESHOLD images to produce 1 frame."
    return 1
  fi

  # Calculate encoding values
  ENCODE_CODEC="libx264"
  IN_WIDTH=$(exiv2 -g Exif.Photo.PixelXDimension -Pv "$INPUT_DIRECTORY/$FIRST_IMAGE")
  IN_HEIGHT=$(exiv2 -g Exif.Photo.PixelYDimension -Pv "$INPUT_DIRECTORY/$FIRST_IMAGE")
  OUT_WIDTH=$((IN_WIDTH * FRAME_SCALE))
  OUT_HEIGHT=$((IN_HEIGHT * FRAME_SCALE))
  FRAME_SIZE=$(printf "%dx%d" "$OUT_WIDTH" "$OUT_HEIGHT")
  OUTPUT_DIRECTORY=$(realpath "$INPUT_DIRECTORY/rendered")
  OUTPUT_PATH=$(printf "%s/timelapse_%sfps_%s_%scrf_%s.mp4" "$OUTPUT_DIRECTORY" "$FRAME_RATE" "$FRAME_SIZE" "$ENCODE_CRF" "$ENCODE_PRESET")

  # Create output directory
  echo "Output directory: $OUTPUT_DIRECTORY"
  mkdir -p "$OUTPUT_DIRECTORY"

  # https://trac.ffmpeg.org/wiki/Encode/H.264
  echo "Generating timelapse now..."
  ffmpeg \
    -i "$INPUT_DIRECTORY/$INPUT_PATTERN" \
    -r "$FRAME_RATE" \
    -s "$FRAME_SIZE" \
    -vcodec "$ENCODE_CODEC" \
    -preset "$ENCODE_PRESET" \
    -crf "$ENCODE_CRF" \
    "$OUTPUT_PATH"
}

function get-timelapse-defaults() {
  # The directory that contains the images to be converted into timelapse
  # By default this is the current directory
  # Note: You should run batch-photo-rename beforehand to rename and order the images by date taken
  INPUT_DIRECTORY="."

  # Frame size modifier/multiplier
  # This value affects how the image size corresponds to the video resolution
  # Example: 1.00 - Image 6000x4000 -> Video 6000x4000
  # Example: 0.50 - Image 6000x4000 -> Video 3000x2000
  # Example: 0.25 - Image 6000x4000 -> Video 1500x1000
  FRAME_SCALE=1

  # The frequency at which consecutive images called frames appear on a display per second
  # Note: the higher the value, the more images will be used per second, decreasing the video length
  # Example: 500 images at 30 fps will produce a video length of 16.6 seconds
  # Example: 500 images at 60 fps will produce a video length of 8.3 seconds
  # Common values (Film): 24
  # Common values (PAL): 25 50
  # Common values (NTSC): 30 60
  FRAME_RATE=30

  # The range of the CRF scale is 0–51, where 0 is lossless, 23 is the default, and 51 is worst quality possible
  # A lower value generally leads to higher quality, and a subjectively sane range is 17–28
  # Consider 17 or 18 to be visually lossless
  # It should look the same or nearly the same as the input but it isn't technically lossless
  ENCODE_CRF=18

  # Use the slowest preset that you have patience for. The available presets in descending order of speed are:
  # ultrafast
  # superfast
  # veryfast
  # faster
  # fast
  # medium – default preset
  # slow
  # slower
  # veryslow
  ENCODE_PRESET="slow"
}

function process-timelapse-arguments() {
  for i in "$@"; do
    case $i in
    --input=*)
      INPUT_DIRECTORY="${i#*=}"
      shift
      ;;
    --scale=*)
      FRAME_SCALE="${i#*=}"
      shift
      ;;
    --fps=*)
      FRAME_RATE="${i#*=}"
      shift
      ;;
    --crf=*)
      ENCODE_CRF="${i#*=}"
      shift
      ;;
    --preset=*)
      ENCODE_PRESET="${i#*=}"
      shift
      ;;
    --help)
      SHOW_CLI_USAGE="yes"
      shift
      ;;
    esac
  done
}

function show-timelapse-cli-usage() {
  echo "===================================================================================================="
  echo "TIMELAPSE VIDEO MAKER"
  echo "===================================================================================================="
  echo "Compiles a directory of images into a timelapse video."
  echo "Please specify one or more of the following options:"
  echo "----------------------------------------------------------------------------------------------------"
  echo "--input=[directory] : The directory that contains the images to be converted into timelapse."
  echo "--scale=[number]    : This value affects how the image size corresponds to the video resolution."
  echo "--fps=[number]      : The frequency at which consecutive images called frames appear on a display per second."
  echo "--crf=[number]      : The range of the CRF scale is 0–51, where 0 is lossless, 23 is the default, and 51 is worst quality possible."
  echo "--preset=[string]   : A collection of options that will provide a certain encoding speed to compression ratio."
  echo "--help              : Show cli usage."
  echo
}
