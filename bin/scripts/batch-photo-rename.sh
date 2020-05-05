#!/usr/bin/env bash

function rename-all-images-in-path() {
  local INDEX=0
  local IMAGE_DIRECTORY="$1"
  local IMAGE_PREFIX="$2"
  local IMAGE_EXTENSION="$3"
  local IN_PATH
  local OUT_PATH

  # SC2016: Expressions don't expand in single quotes, use double quotes for that.
  # shellcheck disable=SC2016
  exiftool \
    -ignoreMinorErrors \
    -table \
    -quiet \
    --composite \
    --printConv \
    -printFormat '$FileName' \
    -fileOrder DateTimeOriginal \
    "$IMAGE_DIRECTORY" | while read -r IMAGE_FILENAME; do
    INDEX=$((INDEX + 1))
    IN_PATH="$IMAGE_DIRECTORY/$IMAGE_FILENAME"
    OUT_PATH=$(printf "%s/%s%04d%s" "$IMAGE_DIRECTORY" "$IMAGE_PREFIX" "$INDEX" "$IMAGE_EXTENSION")

    if [[ ! -e "$IN_PATH" ]]; then
      echo "Skip: $IN_PATH does not exist."
      INDEX=$((INDEX - 1))
      continue
    elif [[ -d "$IN_PATH" ]]; then
      echo "Skip: $IN_PATH is a directory, file expected."
      INDEX=$((INDEX - 1))
      continue
    elif [[ $(file -b "$IN_PATH") != 'JPEG'* ]]; then
      echo "Skip: $IN_PATH is not a JPEG file type."
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
    echo "Success: $IN_PATH -> $OUT_PATH"
  done
}

function batch-photo-rename() {
  local IMAGE_DIRECTORY=${1:-$PWD}
  local IMAGE_PREFIX=${2:-DSC_}
  local IMAGE_EXTENSION=${3:-.JPG}

  if [[ -z "$(ls -A "$IMAGE_DIRECTORY")" ]]; then
    echo "Skip: $IMAGE_DIRECTORY is empty."
    return 0
  fi

  echo "Temp: $IMAGE_DIRECTORY"
  rename-all-images-in-path "$IMAGE_DIRECTORY" ".TEMP_" "$IMAGE_EXTENSION"
  echo "Move: $IMAGE_DIRECTORY"
  rename-all-images-in-path "$IMAGE_DIRECTORY" "$IMAGE_PREFIX" "$IMAGE_EXTENSION"
  echo "Done: $IMAGE_DIRECTORY"
}

function recursive-batch-photo-rename() {
  local DEFAULT_DIR="."
  local INPUT_DIRECTORY=${1:-$DEFAULT_DIR}
  # https://unix.stackexchange.com/a/187175
  find "$INPUT_DIRECTORY" -type d \( ! -name . \) -print0 | sort -z | while IFS= read -rd '' DIR; do
    batch-photo-rename "$(realpath "$DIR")"
  done
}
