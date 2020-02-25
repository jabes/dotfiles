#!/usr/bin/env bash

# Undue any existing aliases to ls
unalias ls

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

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    alias ls="ls ${LS_VERTICAL_FLAGS}"
    alias ll="ls ${LS_LONG_FLAGS}"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if hash gls 2>/dev/null; then
        alias ls="gls ${LS_VERTICAL_FLAGS}"
        alias ll="gls ${LS_LONG_FLAGS}"
    else
        # Non GNU ls
        # https://ss64.com/osx/ls.html
        ALMOST_ALL="-A" # Almost All (list all entries except for . and ..)
        COLOR="-G" # Enable color output
        CLASSIFY="-F" # Classify (append indicator to entries)
        FORMAT_LONG="-l" # List in long format
        FORMAT_VERTICAL="-C" # Force multi-column output
        HUMAN_READABLE="-h" # Human Readable (use unit suffixes)
        alias ls="ls ${CLASSIFY} ${COLOR} ${FORMAT_VERTICAL}"
        alias ll="ls ${CLASSIFY} ${COLOR} ${FORMAT_LONG} ${HUMAN_READABLE} ${ALMOST_ALL}"
    fi
fi
