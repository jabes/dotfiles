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
  local DIR="$1"
  if [[ -d "$DIR" ]]; then
    find "$DIR" -type f -print0 | while IFS='' read -r -d '' GNU_PACKAGE; do
      FILENAME="$(basename "$GNU_PACKAGE")"
      ALIAS="${FILENAME:1}"
      alias "$ALIAS"="$GNU_PACKAGE"
    done
  fi
}

declare -a _directories=(
  "/usr/local/opt/coreutils/bin"
  "/usr/local/opt/findutils/bin"
  "/usr/local/opt/gnu-getopt/bin"
  "/usr/local/opt/gnu-indent/bin"
  "/usr/local/opt/gnu-sed/bin"
  "/usr/local/opt/gnu-tar/bin"
  "/usr/local/opt/gawk/bin"
  "/usr/local/opt/grep/bin"
)

for _directory in "${_directories[@]}"; do
  _alias_gnu_utils "$_directory"
done

unset -f _alias_gnu_utils
unset _directories
unset _directory
