#!/usr/bin/env bash

function rename-all-images-in-path() {
  local INDEX=0
  local IMAGE_DIRECTORY="$1"
  local IMAGE_PREFIX="$2"
  local IMAGE_EXTENSION="$3"
  local IMAGE_METADATA_EXTENSION="$4"
  local IN_FILE
  local IN_PATH
  local OUT_FILE
  local OUT_PATH

  # SC2016: Expressions don't expand in single quotes, use double quotes for that.
  # shellcheck disable=SC2016
  exiftool \
    -ignoreMinorErrors \
    -table \
    -quiet \
    --composite \
    --printConv \
    -extension "$IMAGE_EXTENSION" \
    -printFormat '$FileName' \
    -fileOrder DateTimeOriginal \
    "$IMAGE_DIRECTORY" | while read -r IMAGE_FILENAME
  do
    INDEX=$((INDEX + 1))
    IN_FILE="$IMAGE_FILENAME"
    IN_PATH="$IMAGE_DIRECTORY/$IN_FILE"
    OUT_FILE=$(printf "%s%04d%s" "$IMAGE_PREFIX" "$INDEX" "$IMAGE_EXTENSION")
    OUT_PATH="$IMAGE_DIRECTORY/$OUT_FILE"

    if [[ ! -e "$IN_PATH" ]]; then
      echo "Skip: $IN_PATH does not exist."
      INDEX=$((INDEX - 1))
      continue
    elif [[ -d "$IN_PATH" ]]; then
      echo "Skip: $IN_PATH is a directory, file expected."
      INDEX=$((INDEX - 1))
      continue
    elif [[ "$OUT_PATH" == "$IN_PATH" ]]; then
      echo "Skip: $OUT_PATH and $IN_PATH are the same."
      INDEX=$((INDEX - 1))
      continue
    elif [[ -f "$OUT_PATH" ]]; then
      echo "Skip: $OUT_PATH already exists."
      INDEX=$((INDEX - 1))
      continue
    fi

    mv -i -- "$IN_PATH" "$OUT_PATH"
    echo "Renamed: $IN_PATH -> $OUT_PATH"

    if [[ -f "${IN_PATH}${IMAGE_METADATA_EXTENSION}" ]]; then
      mv -i -- "${IN_PATH}${IMAGE_METADATA_EXTENSION}" "${OUT_PATH}${IMAGE_METADATA_EXTENSION}"
      echo "Renamed: ${IN_PATH}${IMAGE_METADATA_EXTENSION} -> ${OUT_PATH}${IMAGE_METADATA_EXTENSION}"
      sed -i '' -e "s@${IN_FILE}@${OUT_FILE}@g" "${OUT_PATH}${IMAGE_METADATA_EXTENSION}"
      echo "Replaced: ${IN_FILE} -> ${OUT_FILE} in file: ${OUT_PATH}${IMAGE_METADATA_EXTENSION}"
    fi
  done
}

function batch-photo-rename() {
  local IMAGE_DIRECTORY=${1:-$PWD}
  local IMAGE_PREFIX=${2:-DSC_}
  local IMAGE_EXTENSION=${3:-.NEF}
  local IMAGE_METADATA_EXTENSION=${4:-.xmp}

  echo "-- Start ---------------------------------------------------"

  # Get absolute path from relative
  IMAGE_DIRECTORY="$(realpath "$IMAGE_DIRECTORY")"
  echo "Image directory: $IMAGE_DIRECTORY"

  if [[ -z "$(ls -A "$IMAGE_DIRECTORY")" ]]; then
    echo "Skip: $IMAGE_DIRECTORY is empty."
    return 1
  fi

  # Ensure that ExifTool is installed
  if hash "exiftool" 2>/dev/null; then
    echo "ExifTool was found."
  else
    echo >&2 "ExifTool was not found, please install it."
    echo >&2 "brew install exiftool"
    return 1
  fi

  echo "-- Temp ----------------------------------------------------"
  rename-all-images-in-path "$IMAGE_DIRECTORY" ".TEMP_" "$IMAGE_EXTENSION" "$IMAGE_METADATA_EXTENSION"
  echo "-- Move ----------------------------------------------------"
  rename-all-images-in-path "$IMAGE_DIRECTORY" "$IMAGE_PREFIX" "$IMAGE_EXTENSION" "$IMAGE_METADATA_EXTENSION"
  echo "-- Done ----------------------------------------------------"
}

function recursive-batch-photo-rename() {
  local DEFAULT_DIR="."
  local INPUT_DIRECTORY=${1:-$DEFAULT_DIR}
  # https://unix.stackexchange.com/a/187175
  find "$INPUT_DIRECTORY" -type d \( ! -name . \) -print0 | sort -z | while IFS= read -rd '' DIR; do
    batch-photo-rename "$(realpath "$DIR")"
  done
}
