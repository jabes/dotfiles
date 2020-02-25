#!/usr/bin/env bash

# Alias all GNU core utilities
# https://www.gnu.org/software/coreutils/
# gls -> ls
# gpwd -> pwd
# gdate -> date
# ...
GNU_UTILS_DIR="/usr/local/opt/coreutils/bin"
if [ -d "$GNU_UTILS_DIR" ]; then
    find "$GNU_UTILS_DIR" -type f -print0 |
    while IFS='' read -r -d '' GNU_PACKAGE; do
        FILENAME=$(basename "$GNU_PACKAGE")
        alias ${FILENAME:1}="$GNU_PACKAGE"
    done
fi
