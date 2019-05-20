#!/usr/bin/env bash

# https://unix.stackexchange.com/a/187175
function recursive-batch-photo-rename() {
    local DEFAULT_DIR="."
    local INPUT_DIRECTORY=${1:-$DEFAULT_DIR}
	find "$INPUT_DIRECTORY" -type d \( ! -name . \) -print0 | sort -z | while IFS= read -rd '' DIR
	do
		local ABS_DIR=$(realpath "$DIR")
		batch-photo-rename "$ABS_DIR"
	done
}
