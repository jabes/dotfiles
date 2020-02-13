#!/usr/bin/env bash

# https://stackoverflow.com/a/16957078
function search-file-contents() {
	local FILE=$1
	local SEARCH=$2
	if [[ -f "$FILE" ]]; then
		grep -rnw "$FILE" -e "$SEARCH"
	else
		echo "File not found: '$FILE'"
	fi
}
