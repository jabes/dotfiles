#!/usr/bin/env bash

function update-packages {
    echo "Upgrading packages..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --sync --refresh --upgrades --noconfirm
        elif hash pacman 2>/dev/null; then pacman --sync --refresh --upgrades --noconfirm
        elif hash apt 2>/dev/null; then apt update && apt upgrade
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        softwareupdate --install --all
        if hash brew 2>/dev/null; then brew update && brew upgrade; fi
    fi
}

function list-package-updates {
    echo "Listing out-of-date packages..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --show --upgrades
        elif hash pacman 2>/dev/null; then pacman -Syyu -p
        elif hash apt 2>/dev/null; then apt list --upgradable
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        softwareupdate --list
        if hash brew 2>/dev/null; then brew update && brew outdated; fi
    fi
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
            if [ ! -f $HOME/Brewfile ]; then brew bundle dump; fi
            brew bundle --force cleanup
        fi
    fi
}

function clear-package-cache {
    echo "Clearing package cache..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --sync --clean
        elif hash pacman 2>/dev/null; then pacman --sync --clean
        elif hash apt 2>/dev/null; then apt clean
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if hash brew 2>/dev/null; then brew cleanup && rm -rf "$(brew --cache)"; fi
    fi
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
}
