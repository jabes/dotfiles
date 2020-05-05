#!/usr/bin/env bash

# Scales and crops images imported from camera to a standard video resolution
# The aspect ratios are different (3:2 vs 16:9)
# So we will first resize to the desired width and then crop to the desired height
# Example Use: batch-photo-resize . 3840 2160
function batch-photo-resize() {
  # Input parameters
  local IMAGE_DIRECTORY=${1:-$PWD}
  local IMAGE_WIDTH=${2:-1920}
  local IMAGE_HEIGHT=${3:-1080}
  local IMAGE_PREFIX=${4:-DSC_}
  local IMAGE_EXTENSION=${5:-.JPG}

  # Define local vars
  local PATTERN
  local IMAGES
  local IMAGES_TOTAL
  local INPUT_FILE
  local OUTPUT_DIRECTORY
  local OUTPUT_PATH
  local ORIGINAL_WIDTH
  local ORIGINAL_HEIGHT
  local SCALE_WIDTH
  local SCALE_HEIGHT
  local SCALE_GEOMETRY
  local CROP_WIDTH
  local CROP_HEIGHT
  local CROP_OFFSET_X
  local CROP_OFFSET_Y
  local CROP_GEOMETRY

  # Find images in path
  PATTERN="${IMAGE_PREFIX}*${IMAGE_EXTENSION}"
  IMAGES=$(find "$IMAGE_DIRECTORY" -maxdepth 1 -type f -name "$PATTERN")
  IMAGES_TOTAL=$(echo "$IMAGES" | wc -l)
  echo "Processing $IMAGES_TOTAL images..."

  # Created output directory
  OUTPUT_DIRECTORY=$(printf "%s/resized_%ix%i" "$IMAGE_DIRECTORY" "$IMAGE_WIDTH" "$IMAGE_HEIGHT")
  echo "Output directory: $OUTPUT_DIRECTORY"
  mkdir -p "$OUTPUT_DIRECTORY"

  # Loop over each image in path
  echo "$IMAGES" | sort -n | while read -r INPUT_PATH; do

    # Calculate new image size
    INPUT_FILE=$(basename "$INPUT_PATH")
    OUTPUT_PATH="$OUTPUT_DIRECTORY/$INPUT_FILE"
    ORIGINAL_WIDTH=$(exiv2 -g Exif.Photo.PixelXDimension -Pv "$INPUT_PATH")
    ORIGINAL_HEIGHT=$(exiv2 -g Exif.Photo.PixelYDimension -Pv "$INPUT_PATH")
    SCALE_WIDTH=$(printf %.0f "$IMAGE_WIDTH")
    SCALE_HEIGHT=$(printf %.0f "$(echo "($ORIGINAL_HEIGHT / $ORIGINAL_WIDTH) * $SCALE_WIDTH" | bc -l)")
    SCALE_GEOMETRY=$(printf "%dx%d" "$SCALE_WIDTH" "$SCALE_HEIGHT")
    CROP_WIDTH=$(printf %.0f "$IMAGE_WIDTH")
    CROP_HEIGHT=$(printf %.0f "$IMAGE_HEIGHT")
    CROP_OFFSET_X=$(((SCALE_WIDTH - CROP_WIDTH) / 2))
    CROP_OFFSET_Y=$(((SCALE_HEIGHT - CROP_HEIGHT) / 2))
    CROP_GEOMETRY=$(printf "%dx%d+%d+%d" "$CROP_WIDTH" "$CROP_HEIGHT" "$CROP_OFFSET_X" "$CROP_OFFSET_Y")

    # Resize the image
    convert \
      "$INPUT_PATH" \
      -density 300 \
      -quality 100 \
      -gravity Center \
      -resize "$SCALE_GEOMETRY" \
      -crop "$CROP_GEOMETRY" \
      "$OUTPUT_PATH"

    # Update exif meta information
    exiftool \
      -quiet \
      -overwrite_original \
      -exifimagewidth="$CROP_WIDTH" \
      -exifimageheight="$CROP_HEIGHT" \
      "$OUTPUT_PATH"

    # Print status output
    echo "Resized: $OUTPUT_PATH"
  done

  echo "Done."
}
