##!/usr/bin/env bash
#
## Disable any unwanted shell checks
## ---------------------------------
## shellcheck disable=SC2016
## SC2016: Expressions don't expand in single quotes, use double quotes for that.
#
## Run this script in a sub-shell
## This allows us to source this script on shell startup
## And not expose the functions and variables in this script
## So our global context remains unpolluted
#(
#
#  # Get the current script path
#  SCRIPT="$(realpath "$0")"
#  LOCK_FILE="/tmp/StOp_AsKiNg_Me_To_UpDaTe.lock"
#
#  function _is_empty() { if [[ -z "$1" ]]; then return 0; else return 1; fi }
#  function _is_not_empty() { if [[ -n "$1" ]]; then return 0; else return 1; fi }
#  function _is_zsh_shell() { if _is_not_empty "$ZSH_VERSION"; then return 0; else return 1; fi }
#  function _is_bash_shell() { if _is_not_empty "$BASH_VERSION"; then return 0; else return 1; fi }
#  function _is_script_sourced() { if [[ $_ != "$0" ]]; then return 0; else return 1; fi }
#
#  # If a pattern for filename generation has no matches,
#  # print an error instead of leaving it unchanged in the argument list.
#  if _is_zsh_shell; then setopt +o nomatch; fi
#
#  function _color_code() { echo "\e[$1m"; }
#  function _colored_text() {
#    local COLOR="$1"
#    local TEXT="$2"
#    echo -e "$(_color_code "$COLOR")${TEXT}$(_color_code 0)"
#  }
#
#  function _text_black()   { _colored_text 30 "$@"; }
#  function _text_red()     { _colored_text 31 "$@"; }
#  function _text_green()   { _colored_text 32 "$@"; }
#  function _text_yellow()  { _colored_text 33 "$@"; }
#  function _text_blue()    { _colored_text 34 "$@"; }
#  function _text_magenta() { _colored_text 35 "$@"; }
#  function _text_cyan()    { _colored_text 36 "$@"; }
#  function _text_white()   { _colored_text 97 "$@"; }
#
#  function _error() { _text_red >&2 "$1"; }
#  function _abort() {
#    MSG="$1"
#    if _is_not_empty "$MSG"; then _error "$MSG"; fi
#    if _is_script_sourced; then return 1; else exit 1; fi
#  }
#
#  function _trim_whitespace() {
#    echo "$1" | tr -d '[:space:]'
#  }
#
#  function _last_command_executed_successfully() {
#    local CODE="$1"
#    if _is_empty "$CODE"; then CODE="$?"; fi
#    if [[ "$CODE" -eq 0 ]]; then return 0; else return 1; fi
#  }
#
#  function _print_all_done() {
#    local MSG
#    MSG="$(
#      cat <<"EOL"
#         __n__n__
#  .------`-\\00/-'
# /  ##  ## (oo) - Cowabunga, dude!
#/ \## __   ./
#   |//YY \|/
#   |||   |||
#EOL
#    )"
#    _text_yellow "========================================="
#    _text_magenta "$MSG"
#  }
#
#  function _remove_path_and_display_info() {
#    local CACHE_PATH="$1"
#    local CACHE_SIZE
#    local FILES
#    local FILE_COUNT
#    FILES="$(find "${CACHE_PATH:?}" -mindepth 1 -print 2>/dev/null)"
#    FILE_COUNT="$(echo "${#FILES[@]}" | xargs printf %-5s)"
#    CACHE_SIZE="$(du -h -s "$CACHE_PATH" | cut -f 1 | xargs printf %-8s)"
#    while IFS=$'\n' read -r FILE; do rm -r -f "$FILE"; done <<<"$FILES"
#    echo "Items removed: $FILE_COUNT Total size: $CACHE_SIZE Path: $CACHE_PATH"
#  }
#
#  function _wait_for_process_to_finish() {
#    local PID="$1"
#    while ps -p "$PID" >/dev/null; do
#      echo -n "."
#      sleep 1
#    done
#  }
#
#  function _run_process_in_background() {
#    local CMD_NAME="$1"
#    local CMD_STRING="$2"
#    if hash "$CMD_NAME" 2>/dev/null; then
#      echo -n "Updating $CMD_NAME "
#      # quietly launch a background job while retaining control of the job
#      {
#        set +m
#        sh --login -c "$CMD_STRING" &
#        disown
#      } >/dev/null 2>&1
#      _wait_for_process_to_finish "$!"
#      _text_green " Done!"
#    else
#      _abort "Command not found: $CMD_NAME"
#    fi
#  }
#
#  function _run_sudo_process_in_background() {
#    local CMD_NAME="$1"
#    local CMD_STRING="$2"
#    if hash "$CMD_NAME" 2>/dev/null; then
#      echo -n "Updating (sudo) $CMD_NAME "
#      # quietly launch a background job while retaining control of the job
#      set +m
#      {
#        sudo sh --login -c "$CMD_STRING" &
#        disown
#      } >/dev/null 2>&1
#      _wait_for_process_to_finish "$!"
#      _text_green " Done!"
#    else
#      _abort "Command not found: $CMD_NAME"
#    fi
#  }
#
#  function _initiate_sudo_privileges() {
#    local SUDO_RESULT_MSG
#    local SUDO_RESULT_CODE
#    local CAN_RUN_SUDO
#    CAN_RUN_SUDO=$(sudo -n uptime 2>&1 | grep -c "load")
#    if [[ "$CAN_RUN_SUDO" -gt 0 ]]; then
#      _text_green "Sudo privileges already granted."
#    else
#      stty -echo
#      read -r -s -p "Give me your password: " PASSWORD
#      # -S : read the password from the standard input
#      # -p : override the default password prompt
#      SUDO_RESULT_MSG="$(echo "$PASSWORD" | sudo -S -p '' echo 'Your password is mine now!' 2>&1)"
#      SUDO_RESULT_CODE="$?"
#      unset PASSWORD
#      stty echo
#      if _last_command_executed_successfully "$SUDO_RESULT_CODE"
#      then _text_green "$SUDO_RESULT_MSG"
#      else _error "$(_trim_whitespace "$SUDO_RESULT_MSG")" && _initiate_sudo_privileges
#      fi
#    fi
#  }
#
#  function _add_user_to_sudoers() {
#    local USER
#    USER="$(whoami)"
#    echo -n "Adding user '$(_text_yellow "$USER")' to sudoers..."
#    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$USER" 1>/dev/null
#    _text_green "Done"
#  }
#
#  function _check_shell() {
#    if _is_bash_shell; then
#      _text_green "Your shell is correct!"
#      return 0
#    else
#      _error "Your shell is incorrect."
#      _text_yellow "Running again with proper shell..."
#      bash --login "$SCRIPT" --no-check-lock
#      return 1
#    fi
#  }
#
#  function _upgrade_packages() {
#    _text_yellow "========================================="
#    _text_yellow "= Upgrading packages ===================="
#    _text_yellow "========================================="
#    if [[ "$OSTYPE" == 'linux-gnu' ]]; then
#      _run_process_in_background 'yay' 'yay --sync --refresh --sysupgrade --noconfirm'
#      _run_sudo_process_in_background 'pacman' 'pacman --sync --refresh --sysupgrade --noconfirm'
#      _run_sudo_process_in_background 'apt' 'apt update && apt dist-upgrade --assume-yes --no-install-recommends --fix-broken --fix-missing --quiet'
#    elif [[ "$OSTYPE" == 'darwin'* ]]; then
#      _run_process_in_background 'brew' 'brew update && brew upgrade'
#    fi
#    _run_process_in_background 'npm' 'npm update --global'
#    _run_process_in_background 'composer' 'composer self-update && composer global update --no-interaction --no-progress --no-suggest'
#    _run_process_in_background 'pip3' 'pip3 list --outdated --format=freeze | grep --invert-match "^\-e" | cut --delimiter="=" --fields=1 | xargs -n1 pip3 install --upgrade'
#  }
#
#  function _remove_unused_packages() {
#    _text_yellow "========================================="
#    _text_yellow "= Removing orphan packages =============="
#    _text_yellow "========================================="
#    if [[ "$OSTYPE" == 'linux-gnu' ]]; then
#      _run_process_in_background 'yay' 'yay --yay --clean'
#      _run_sudo_process_in_background 'pacman' 'pacman --remove --nosave --recursive $(pacman --query --deps --unrequired --quiet)'
#      _run_sudo_process_in_background 'apt' 'apt autoremove --purge'
#    elif [[ "$OSTYPE" == 'darwin'* ]]; then
#      _run_process_in_background 'brew' 'brew cleanup --prune=0 && brew bundle dump --force && brew bundle cleanup --force'
#    fi
#  }
#
#  function _clear_package_cache() {
#    _text_yellow "========================================="
#    _text_yellow "= Clearing package cache ================"
#    _text_yellow "========================================="
#    if [[ "$OSTYPE" == 'linux-gnu' ]]; then
#      _run_process_in_background 'yay' 'yay --sync --clean'
#      _run_sudo_process_in_background 'pacman' 'pacman --sync --clean'
#      _run_sudo_process_in_background 'apt' 'apt clean'
#      if hash pip3 2>/dev/null; then _remove_path_and_display_info "$HOME/.cache/pip"; fi
#    elif [[ "$OSTYPE" == 'darwin'* ]]; then
#      if hash brew 2>/dev/null; then _remove_path_and_display_info "$(brew --cache)"; fi
#      if hash pip3 2>/dev/null; then _remove_path_and_display_info "$HOME/Library/Caches/pip"; fi
#    fi
#    if hash npm 2>/dev/null; then _remove_path_and_display_info "$(npm config get cache)"; fi
#    if hash composer 2>/dev/null; then _remove_path_and_display_info "$(composer --working-dir="$HOME" config --global cache-dir)"; fi
#  }
#
#  function _do_upgrade() {
#    if _check_shell; then
#      _initiate_sudo_privileges
#      _add_user_to_sudoers
#      _upgrade_packages
#      _remove_unused_packages
#      _clear_package_cache
#      _create_lock_file
#      _print_all_done
#    fi
#  }
#
#  function _ask_to_upgrade() {
#    _text_cyan "Would you like to update your system? [yes/no]"
#    read -r response
#    case "$response" in
#    [yY][eE][sS] | [yY]) _do_upgrade ;;
#    *) _abort "Abort, no action taken." ;;
#    esac
#  }
#
#  function _check_lock_file() {
#    local T1
#    local T2
#    local TIMEDIFF_SECONDS
#    local TIMEDIFF_MINUTES
#    local TIMEDIFF_HOURS
#    # Check if lock file exists or has a date greater than 24 hours
#    if [[ -e "$LOCK_FILE" ]]; then
#      T1=$(cat "$LOCK_FILE")
#      T2=$(date +%s)
#      TIMEDIFF_SECONDS=$((T2 - T1))
#      TIMEDIFF_MINUTES=$((TIMEDIFF_SECONDS / 60))
#      TIMEDIFF_HOURS=$((TIMEDIFF_MINUTES / 60))
#      if [[ "$TIMEDIFF_HOURS" -gt 24 ]]
#      then _ask_to_upgrade
#      fi
#    else _ask_to_upgrade
#    fi
#  }
#
#  function _create_lock_file() {
#    date +%s >"$LOCK_FILE"
#  }
#
#  # Process arguments
#  CHECK_LOCK_FILE=1
#  for i in "$@"; do
#    case $i in
#    -n | --no-check-lock)
#      CHECK_LOCK_FILE=0
#      shift
#      ;;
#    *) _abort "Invalid argument: $i" ;;
#    esac
#  done
#
#  # Run check on session start
#  if [[ "$CHECK_LOCK_FILE" -eq 1 ]]
#  then _check_lock_file
#  else _do_upgrade
#  fi
#
#)
