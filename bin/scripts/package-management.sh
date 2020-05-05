#!/usr/bin/env bash
# SC2016: Expressions don't expand in single quotes, use double quotes for that.
# shellcheck disable=SC2016

setopt +o nomatch

function _color_code() { echo "\e[$1m"; }
function _colored_text() {
  local COLOR="$1"
  local TEXT="$2"
  echo -e "$(_color_code "$COLOR")${TEXT}$(_color_code 0)"
}

function _text_black() { _colored_text 30 "$@"; }
function _text_red() { _colored_text 31 "$@"; }
function _text_green() { _colored_text 32 "$@"; }
function _text_yellow() { _colored_text 33 "$@"; }
function _text_blue() { _colored_text 34 "$@"; }
function _text_magenta() { _colored_text 35 "$@"; }
function _text_cyan() { _colored_text 36 "$@"; }
function _text_white() { _colored_text 97 "$@"; }

function _print_all_done() {
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
  _text_yellow "========================================="
  _text_magenta "$MSG"
}

function _remove_path_and_display_info() {
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

function _run_process_in_background() {
  local CMD_NAME="$1"
  local CMD_STRING="$2"
  local PID
  if hash "$CMD_NAME" >/dev/null 2>&1; then
    PID=$(
      nohup sh -c "$CMD_STRING" >/dev/null 2>&1 &
      echo $!
    )
    echo -n "Updating $CMD_NAME "
    while ps -p "$PID" >/dev/null 2>&1; do echo -n "." && sleep 1; done
    _text_green " Done!"
  fi
}

function _upgrade_packages() {
  _text_yellow "========================================="
  _text_yellow "= Upgrading packages ===================="
  _text_yellow "========================================="
  if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    _run_process_in_background 'yay' 'yay --sync --refresh --sysupgrade --noconfirm'
    _run_process_in_background 'pacman' 'pacman --sync --refresh --sysupgrade --noconfirm'
    _run_process_in_background 'apt' 'apt update && apt dist-upgrade --assume-yes --no-install-recommends --fix-broken --fix-missing --quiet'
  elif [[ "$OSTYPE" == 'darwin'* ]]; then
    _run_process_in_background 'brew' 'brew update && brew upgrade'
  fi
  _run_process_in_background 'npm' 'npm update --global'
  _run_process_in_background 'composer' 'composer self-update && composer global update --no-interaction --no-progress --no-suggest'
  _run_process_in_background 'pip3' 'pip3 list --outdated --format=freeze | grep --invert-match "^\-e" | cut --delimiter="=" --fields=1 | xargs -n1 pip3 install --upgrade'
  _run_process_in_background 'gcloud' 'gcloud components update'
  _run_process_in_background 'op' 'op update'
}

function _remove_unused_packages() {
  _text_yellow "========================================="
  _text_yellow "= Removing orphan packages =============="
  _text_yellow "========================================="
  if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    _run_process_in_background 'yay' 'yay --yay --clean'
    _run_process_in_background 'pacman' 'pacman --remove --nosave --recursive $(pacman --query --deps --unrequired --quiet)'
    _run_process_in_background 'apt' 'apt autoremove --purge'
  elif [[ "$OSTYPE" == 'darwin'* ]]; then
    _run_process_in_background 'brew' 'brew cleanup --prune && brew bundle dump --force && brew bundle cleanup --force'
  fi
  _run_process_in_background 'npm' 'npm prune --global'
}

function _clear_package_cache() {
  _text_yellow "========================================="
  _text_yellow "= Clearing package cache ================"
  _text_yellow "========================================="
  if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    _run_process_in_background 'yay' 'yay --sync --clean'
    _run_process_in_background 'pacman' 'pacman --sync --clean'
    _run_process_in_background 'apt' 'apt clean'
    if hash pip3 2>/dev/null; then _remove_path_and_display_info "$HOME/.cache/pip"; fi
  elif [[ "$OSTYPE" == 'darwin'* ]]; then
    if hash brew 2>/dev/null; then _remove_path_and_display_info "$(brew --cache)"; fi
    if hash pip3 2>/dev/null; then _remove_path_and_display_info "$HOME/Library/Caches/pip"; fi
  fi
  if hash npm 2>/dev/null; then _remove_path_and_display_info "$(npm config get cache)"; fi
  if hash composer 2>/dev/null; then _remove_path_and_display_info "$(composer config --global cache-dir)"; fi
}

function _ask_to_upgrade() {
  _text_cyan "Would you like to update your system? [yes/no]"
  read -r response
  case "$response" in
  [yY][eE][sS] | [yY])
    _upgrade_packages
    _remove_unused_packages
    _clear_package_cache
    _print_all_done
    ;;
  *)
    # Do nothing
    ;;
  esac
}

function _check_lock_file() {
  local T1
  local T2
  local TIMEDIFF_SECONDS
  local TIMEDIFF_MINUTES
  local TIMEDIFF_HOURS
  # Check if lock file exists or has a date greater than 24 hours
  local LOCK_FILE="/tmp/StOp_AsKiNg_Me_To_UpDaTe.lock"
  if [[ -e "$LOCK_FILE" ]]; then
    T1=$(cat "$LOCK_FILE")
    T2=$(date +%s)
    TIMEDIFF_SECONDS=$((T2 - T1))
    TIMEDIFF_MINUTES=$((TIMEDIFF_SECONDS / 60))
    TIMEDIFF_HOURS=$((TIMEDIFF_MINUTES / 60))
    if [[ "$TIMEDIFF_HOURS" -gt 24 ]]; then
      _ask_to_upgrade
    fi
  else
    _ask_to_upgrade
  fi
  # Create lock file after upgrade
  date +%s >"$LOCK_FILE"
}

# Run check on session start
_check_lock_file

# Unset all functions to keep shell environment clean
unset -f _color_code
unset -f _colored_text
unset -f _text_black
unset -f _text_red
unset -f _text_green
unset -f _text_yellow
unset -f _text_blue
unset -f _text_magenta
unset -f _text_cyan
unset -f _text_white
unset -f _print_all_done
unset -f _remove_path_and_display_info
unset -f _run_process_in_background
unset -f _upgrade_packages
unset -f _remove_unused_packages
unset -f _clear_package_cache
unset -f _ask_to_upgrade
unset -f _check_lock_file
