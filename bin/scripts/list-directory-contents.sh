#!/usr/bin/env bash
# SC2139: This expands when defined, not when used. Consider escaping.
# shellcheck disable=SC2139

LS_BASE_FLAGS=(
  "--group-directories-first"
  "--classify"
  "--color"
)

LS_VERTICAL_FLAGS=(
  "${LS_BASE_FLAGS[@]}"
  "--format=vertical"
)

LS_LONG_FLAGS=(
  "${LS_BASE_FLAGS[@]}"
  "--format=long"
  "--human-readable"
  "--almost-all"
)

# Undue any existing aliases to ls
unalias ls

function _alias_ls() {
  alias ls="$1 ${LS_VERTICAL_FLAGS[*]}"
  alias ll="$1 ${LS_LONG_FLAGS[*]}"
}

function _linux_alias_gnu_ls() { _alias_ls "ls"; }
function _osx_alias_gnu_ls() { _alias_ls "gls"; }
function _osx_alias_non_gnu_ls() {
  # Non GNU ls
  # https://ss64.com/osx/ls.html
  local ALMOST_ALL="-A"      # Almost All (list all entries except for . and ..)
  local COLOR="-G"           # Enable color output
  local CLASSIFY="-F"        # Classify (append indicator to entries)
  local FORMAT_LONG="-l"     # List in long format
  local FORMAT_VERTICAL="-C" # Force multi-column output
  local HUMAN_READABLE="-h"  # Human Readable (use unit suffixes)
  alias ls="ls ${CLASSIFY} ${COLOR} ${FORMAT_VERTICAL}"
  alias ll="ls ${CLASSIFY} ${COLOR} ${FORMAT_LONG} ${HUMAN_READABLE} ${ALMOST_ALL}"
}

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  _linux_alias_gnu_ls
elif [[ "$OSTYPE" == "darwin"* ]]; then
  if hash gls 2>/dev/null; then
    _osx_alias_gnu_ls
  else
    _osx_alias_non_gnu_ls
  fi
fi

# Unset vars
unset LS_BASE_FLAGS
unset LS_VERTICAL_FLAGS
unset LS_LONG_FLAGS

# Unset functions
unset -f _linux_alias_gnu_ls
unset -f _osx_alias_gnu_ls
unset -f _osx_alias_non_gnu_ls
