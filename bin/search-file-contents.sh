#!/usr/bin/env bash

# https://stackoverflow.com/a/16957078
function search-file-contents() {
    local FILE_PATH=$1
    local SEARCH_PATTERN=$2
    grep -rnw "$FILE_PATH" -e "$SEARCH_PATTERN"
}
