#!/usr/bin/env bash

# https://stackoverflow.com/a/16957078
function search-file-contents() {
  local FILE="$1"
  if [[ -z "$FILE" ]]; then
    echo "You must provide a file to search."
    return 0
  fi

  local SEARCH="$2"
  if [[ -z "$SEARCH" ]]; then
    echo "You must provide a search pattern."
    return 0
  fi

  if [[ -f "$FILE" ]]; then
    grep --recursive --line-number --word-regexp "$FILE" --regexp="$SEARCH"
  else
    echo "File not found: '$FILE'"
  fi
}
