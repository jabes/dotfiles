#!/usr/bin/env bash

function upgrade-packages {
    echo "Upgrading packages..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --sync --refresh --sysupgrade --noconfirm
        elif hash pacman 2>/dev/null; then pacman --sync --refresh --sysupgrade --noconfirm
        elif hash apt 2>/dev/null; then apt update --quiet=2 && apt upgrade --quiet --assume-yes
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if hash brew 2>/dev/null; then
            brew update >/dev/null
            local RESULT=$(brew upgrade)
            if [ -z $RESULT ]; then echo "No packages to update."
            else echo $RESULT; fi
        fi
    fi
    echo "Done."
}

function list-upgradable-packages {
    echo "Listing out-of-date packages..."
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        if hash yay 2>/dev/null; then yay --sync --refresh && yay --show --upgrades
        elif hash pacman 2>/dev/null; then pacman --sync --refresh && pacman --query --upgrades
        elif hash apt 2>/dev/null; then apt update --quiet=2 && apt list --quiet --upgradable
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if hash brew 2>/dev/null; then
            brew update >/dev/null
            local RESULT=$(brew outdated)
            if [ -z $RESULT ]; then echo "No packages are out of date."
            else echo $RESULT; fi
        fi
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
        if hash brew 2>/dev/null; then brew cleanup && rm -rf "$(brew --cache)"; fi
    fi
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
