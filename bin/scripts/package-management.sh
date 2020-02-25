#!/usr/bin/env bash

function --remove-path-and-display-info {
    local CACHE_PATH="$1"
    local CACHE_SIZE="$(du --human-readable --summarize $CACHE_PATH)"
    local FILE_COUNT="$(find $CACHE_PATH/{*,.*} -print 2>/dev/null | wc --lines)"
    rm --recursive --force $CACHE_PATH/{*,.*}
    echo "Removed $FILE_COUNT items: $CACHE_SIZE"
}

function upgrade-packages {
    echo "Upgrading packages..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --sync --refresh --sysupgrade --noconfirm
        elif hash pacman 2>/dev/null; then pacman --sync --refresh --sysupgrade --noconfirm
        elif hash apt 2>/dev/null; then apt update --quiet=3 && apt upgrade --quiet=2 --assume-yes
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if hash brew 2>/dev/null; then
            echo -n "Brew: "
            brew update >/dev/null
            local RESULT="$(brew upgrade 2>&1)"
            if [ -z $RESULT ]; then echo "Up-to-date."
            else echo $RESULT; fi
        fi
    fi
    if hash npm 2>/dev/null; then
        echo -n "NPM: "
        local RESULT="$(npm update --global 2>&1)"
        if [ -z $RESULT ]; then echo "Up-to-date."
        else echo $RESULT; fi
    fi
    if hash composer 2>/dev/null; then
        echo -n "Composer: "
        local RESULT="$(composer global update --no-interaction --no-progress --no-suggest 2>&1)"
        if [[ $RESULT == *"Nothing to install or update"* ]]; then echo "Up-to-date."
        else echo $RESULT; fi
    fi
    echo "Done."
}

function list-upgradable-packages {
    echo "Listing out-of-date packages..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --sync --refresh && yay --show --upgrades
        elif hash pacman 2>/dev/null; then pacman --sync --refresh && pacman --query --upgrades
        elif hash apt 2>/dev/null; then apt update --quiet=3 && apt list --quiet=2 --upgradable
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if hash brew 2>/dev/null; then
            echo -n "Brew: ";
            brew update >/dev/null
            local RESULT="$(brew outdated 2>&1)"
            if [ -z $RESULT ]; then echo "No packages are out of date."
            else echo $RESULT; fi
        fi
    fi
    if hash npm 2>/dev/null; then
        echo -n "NPM: "
        local RESULT="$(npm outdated --global 2>&1)"
        if [ -z $RESULT ]; then echo "No packages are out of date."
        else echo $RESULT; fi
    fi
    if hash composer 2>/dev/null; then
        echo -n "Composer: "
        local RESULT="$(composer global outdated --no-interaction 2>&1 | tail -n +2)"
        if [ -z $RESULT ]; then echo "No packages are out of date."
        else echo $RESULT; fi
    fi
    echo "Done."
}

function remove-unused-packages {
    echo "Removing orphan packages..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --yay --clean
        elif hash pacman 2>/dev/null; then pacman --remove --nosave --recursive $(pacman --query --deps --unrequired --quiet)
        elif hash apt 2>/dev/null; then apt autoremove
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if hash brew 2>/dev/null; then
            brew bundle dump --force
            brew bundle cleanup --force
        fi
    fi
    echo "Done."
}

function clear-package-cache {
    echo "Clearing package cache..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --sync --clean
        elif hash pacman 2>/dev/null; then pacman --sync --clean
        elif hash apt 2>/dev/null; then apt clean
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if hash brew 2>/dev/null; then --remove-path-and-display-info $(brew --cache); fi
    fi
    if hash npm 2>/dev/null; then --remove-path-and-display-info $(npm config get cache); fi
    if hash composer 2>/dev/null; then --remove-path-and-display-info $(composer config --global cache-dir); fi
    echo "Done."
}

function search-remote-package {
    local PATTERN="$1"
    echo "Searching for '$PATTERN' remotely..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --sync --search $PATTERN
        elif hash pacman 2>/dev/null; then pacman --sync --search $PATTERN
        elif hash apt 2>/dev/null; then apt search $PATTERN
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if hash brew 2>/dev/null; then brew search $PATTERN; fi
    fi
    echo "Done."
}

function search-local-package {
    local PATTERN="$1"
    echo "Searching for '$PATTERN' locally..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --query | grep $PATTERN
        elif hash pacman 2>/dev/null; then pacman --query | grep $PATTERN
        elif hash apt 2>/dev/null; then apt list --installed | grep $PATTERN
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if hash brew 2>/dev/null; then brew list | grep $PATTERN; fi
    fi
    echo "Done."
}

SCRIPT_DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1; pwd -P)"
SCRIPT_FILENAME=$(basename "$0")
SCRIPT_FULL_PATH="$SCRIPT_DIR/$SCRIPT_FILENAME"

function sudo-upgrade-packages { sudo bash -c "source $SCRIPT_FULL_PATH && upgrade-packages" }
function sudo-list-upgradable-packages { sudo bash -c "source $SCRIPT_FULL_PATH && list-upgradable-packages" }
function sudo-remove-unused-packages { sudo bash -c "source $SCRIPT_FULL_PATH && remove-unused-packages" }
function sudo-clear-package-cache { sudo bash -c "source $SCRIPT_FULL_PATH && clear-package-cache" }
function sudo-search-remote-package { sudo bash -c "source $SCRIPT_FULL_PATH && search-remote-package" }
function sudo-search-local-package { sudo bash -c "source $SCRIPT_FULL_PATH && search-local-package" }
