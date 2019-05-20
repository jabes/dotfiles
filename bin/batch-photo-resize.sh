#!/usr/bin/env bash

# Scales and crops images imported from camera to a standard video resolution
# The aspect ratios are different (3:2 vs 16:9)
# So we will first resize to the desired width and then crop to the desired height 
# Example Use: batch-photo-resize . 3840 2160
function batch-photo-resize() {
    local IMAGE_DIRECTORY=${1:-$PWD}
    local IMAGE_WIDTH=${2:-1920}
    local IMAGE_HEIGHT=${3:-1080}
    local IMAGE_PREFIX=${4:-DSC_}
    local IMAGE_EXTENSION=${5:-.JPG}
    local PATTERN="${IMAGE_PREFIX}*${IMAGE_EXTENSION}"
    local IMAGES=$(find "$IMAGE_DIRECTORY" -maxdepth 1 -type f -name "$PATTERN")
    local IMAGES_TOTAL=$(echo "$IMAGES" | wc -l)
    echo "Processing $IMAGES_TOTAL images..."
    
    local OUTPUT_DIRECTORY=$(printf "%s/resized_%ix%i" $IMAGE_DIRECTORY $IMAGE_WIDTH $IMAGE_HEIGHT)
    echo "Output directory: $OUTPUT_DIRECTORY"
    mkdir -p "$OUTPUT_DIRECTORY"
    
    echo "$IMAGES" | sort -n | while read INPUT_PATH
    do
        local INPUT_FILE=$(basename "$INPUT_PATH")
        local OUTPUT_PATH="$OUTPUT_DIRECTORY/$INPUT_FILE"
        local ORIGINAL_WIDTH=$(exiv2 -g Exif.Photo.PixelXDimension -Pv $INPUT_PATH)
        local ORIGINAL_HEIGHT=$(exiv2 -g Exif.Photo.PixelYDimension -Pv $INPUT_PATH)
        local SCALE_WIDTH=$(printf %.0f "$IMAGE_WIDTH")
        local SCALE_HEIGHT=$(printf %.0f $(echo "($ORIGINAL_HEIGHT / $ORIGINAL_WIDTH) * $SCALE_WIDTH" | bc -l))
        local SCALE_GEOMETRY=$(printf "%dx%d" "$SCALE_WIDTH" "$SCALE_HEIGHT")
        local CROP_WIDTH=$(printf %.0f "$IMAGE_WIDTH")
        local CROP_HEIGHT=$(printf %.0f "$IMAGE_HEIGHT")
        local CROP_OFFSET_X=$(( ($SCALE_WIDTH - $CROP_WIDTH) / 2 ))
        local CROP_OFFSET_Y=$(( ($SCALE_HEIGHT - $CROP_HEIGHT) / 2 ))
        local CROP_GEOMETRY=$(printf "%dx%d+%d+%d" "$CROP_WIDTH" "$CROP_HEIGHT" "$CROP_OFFSET_X" "$CROP_OFFSET_Y")

        echo "Write: $OUTPUT_PATH"

        convert \
            "$INPUT_PATH" \
            -density 300 \
            -quality 100 \
            -gravity Center \
            -resize "$SCALE_GEOMETRY" \
            -crop "$CROP_GEOMETRY" \
            "$OUTPUT_PATH"

        exiftool \
            -quiet \
            -overwrite_original \
            -exifimagewidth="$CROP_WIDTH" \
            -exifimageheight="$CROP_HEIGHT" \
            "$OUTPUT_PATH"
    done

    echo "Done."
}
