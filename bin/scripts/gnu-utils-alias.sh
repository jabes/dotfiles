#!/usr/bin/env bash
# SC2139: This expands when defined, not when used. Consider escaping.
# shellcheck disable=SC2139

# Alias all GNU core utilities
# https://www.gnu.org/software/coreutils/
# gls -> ls
# gpwd -> pwd
# gdate -> date
# ...
function _alias_gnu_utils() {
  local ALIAS
  local FILENAME
  local GNU_UTILS_DIR="/usr/local/opt/coreutils/bin"
  if [[ -d "$GNU_UTILS_DIR" ]]; then
    find "$GNU_UTILS_DIR" -type f -print0 | while IFS='' read -r -d '' GNU_PACKAGE; do
      FILENAME="$(basename "$GNU_PACKAGE")"
      ALIAS="${FILENAME:1}"
      alias "$ALIAS"="$GNU_PACKAGE"
    done
  fi
}

_alias_gnu_utils
unset -f _alias_gnu_utils
