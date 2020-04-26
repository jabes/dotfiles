#!/usr/bin/env bash

setopt +o nomatch

function color_code() { echo "\e[$1m"; }
function colored_text() {
  local COLOR="$1"
  local TEXT="$2"
  local OUTPUT
  OUTPUT="$(color_code "$COLOR")${TEXT}$(color_code 0)"
  echo -e "$OUTPUT"
}

function text_black() { colored_text 30 "$@"; }
function text_red() { colored_text 31 "$@"; }
function text_green() { colored_text 32 "$@"; }
function text_yellow() { colored_text 33 "$@"; }
function text_blue() { colored_text 34 "$@"; }
function text_magenta() { colored_text 35 "$@"; }
function text_cyan() { colored_text 36 "$@"; }
function text_white() { colored_text 97 "$@"; }

function remove-path-and-display-info() {
  local CACHE_PATH="$1"
  local CACHE_SIZE
  local FILES
  local FILE_COUNT
  FILES="$(find "${CACHE_PATH:?}" -mindepth 1 -print 2>/dev/null)"
  FILE_COUNT="$(echo "${#FILES[@]}" | xargs printf %-5s)"
  CACHE_SIZE="$(du --human-readable --summarize "$CACHE_PATH" | cut --fields=1 | xargs printf %-8s)"
  while IFS=$'\n' read -r FILE; do rm --recursive --force "$FILE"; done <<<"$FILES"
  echo "Items removed: $FILE_COUNT Total size: $CACHE_SIZE Path: $CACHE_PATH"
}

function run-process-in-background() {
  local CMD_NAME="$1"
  local CMD_STRING="$2"
  local PID
  if hash "$CMD_NAME" >/dev/null 2>&1; then
    PID=$(nohup sh -c "$CMD_STRING" >/dev/null 2>&1 & echo $!)
    echo -n "Updating $CMD_NAME "
    while ps -p "$PID" >/dev/null; do echo -n "." && sleep 1; done
    text_green " Done!"
  fi
}

function ask-to-upgrade() {
  # Create a lock file to prevent further requests until cleared
  local LOCK_FILE="/tmp/StOp_AsKiNg_Me_To_UpDaTe.lock"
  if [[ -e "$LOCK_FILE" ]]; then
    # Lock file exists...
    # No need to prompt user at this point
    echo -n
  else
    text_cyan "Would you like to update your system? [yes/no]"
    read -r response
    case "$response" in
    [yY][eE][sS] | [yY])
      upgrade-packages
      remove-unused-packages
      clear-package-cache
      print-all-done
      date +%s >"$LOCK_FILE"
      ;;
    *)
      # Do nothing
      ;;
    esac
  fi
}

function upgrade-packages() {
  text_yellow "========================================="
  text_yellow "= Upgrading packages ===================="
  text_yellow "========================================="
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    run-process-in-background "yay" "yay --sync --refresh --sysupgrade --noconfirm"
    run-process-in-background "pacman" "pacman --sync --refresh --sysupgrade --noconfirm"
    run-process-in-background "apt" "apt update && apt dist-upgrade --assume-yes --no-install-recommends --fix-broken --fix-missing --quiet"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    run-process-in-background "brew" "brew update && brew upgrade"
  fi
  run-process-in-background "npm" "npm update --global"
  run-process-in-background "composer" "composer self-update && composer global update --no-interaction --no-progress --no-suggest"
  run-process-in-background "pip3" "pip3 list --outdated --format=freeze | grep --invert-match '^\-e' | cut --delimiter='=' --fields=1 | xargs -n1 pip3 install --upgrade"
}

function remove-unused-packages() {
  text_yellow "========================================="
  text_yellow "= Removing orphan packages =============="
  text_yellow "========================================="
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    run-process-in-background "yay" "yay --yay --clean"
    run-process-in-background "pacman" "pacman --remove --nosave --recursive $(pacman --query --deps --unrequired --quiet)"
    run-process-in-background "apt" "apt autoremove --purge"
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    run-process-in-background "brew" "brew cleanup --prune && \
                                            brew bundle dump --force && \
                                            brew bundle cleanup --force"
  fi
  run-process-in-background "npm" "npm prune --global"
}

function clear-package-cache() {
  text_yellow "========================================="
  text_yellow "= Clearing package cache ================"
  text_yellow "========================================="
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    run-process-in-background "yay" "yay --sync --clean"
    run-process-in-background "pacman" "pacman --sync --clean"
    run-process-in-background "apt" "apt clean"
    if hash pip3 2>/dev/null; then remove-path-and-display-info "$HOME/.cache/pip"; fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if hash brew 2>/dev/null; then remove-path-and-display-info "$(brew --cache)"; fi
    if hash pip3 2>/dev/null; then remove-path-and-display-info "$HOME/Library/Caches/pip"; fi
  fi
  if hash npm 2>/dev/null; then remove-path-and-display-info "$(npm config get cache)"; fi
  if hash composer 2>/dev/null; then remove-path-and-display-info "$(composer config --global cache-dir)"; fi
}

function print-all-done() {
  local MSG
  MSG="$(
    cat <<"EOL"
         __n__n__
  .------`-\\00/-'
 /  ##  ## (oo) - Cowabunga, dude!
/ \## __   ./
   |//YY \|/
   |||   |||
EOL
  )"
  text_yellow "========================================="
  text_magenta "$MSG"
}

ask-to-upgrade

