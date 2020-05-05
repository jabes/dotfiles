#!/usr/bin/env bash

CUSTOM_PATHS=(
  "$HOME/.composer/vendor/bin"
  "$HOME/.google-cloud-sdk/bin"
  "$HOME/.npm-packages/bin"
)

CUSTOM_PATH=$(
  IFS=:
  echo "${CUSTOM_PATHS[*]}"
)

export PATH="$CUSTOM_PATH:$PATH"

unset CUSTOM_PATHS
unset CUSTOM_PATH
