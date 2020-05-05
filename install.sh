#!/usr/bin/env bash

REPO_URL="git@github.com:jabes/dotfiles.git"
INSTALL_PATH="$HOME/.dotfiles"
LOCAL_BIN_SCRIPTS_PATH="$HOME/bin/scripts"

echo "Cloning repo..."
git clone --recurse-submodules -j8 "$REPO_URL" "$INSTALL_PATH"

echo "Linking files..."
ln -s "$INSTALL_PATH/.npmrc" "$HOME/.npmrc"
ln -s "$INSTALL_PATH/.zshrc" "$HOME/.zshrc"
ln -s "$INSTALL_PATH/submodules/timelapse-deflicker/timelapse-deflicker.pl" "$INSTALL_PATH/bin/scripts/timelapse-deflicker.pl"

if [[ "$OSTYPE" == 'linux-gnu' ]]; then
  SUBL_PATH=$(command -v subl3)
elif [[ "$OSTYPE" == 'darwin'* ]]; then
  SUBL_PATH=$(find /Applications -type f -name subl)
fi

if [[ -z "$SUBL_PATH" ]]; then
  echo "Could not link sublime because it was not found."
else
  ln -s "$SUBL_PATH" "$HOME/bin/subl"
fi

echo "Creating custom paths..."
mkdir -p "$LOCAL_BIN_SCRIPTS_PATH"
cp "$INSTALL_PATH/custom-paths.sh" "$LOCAL_BIN_SCRIPTS_PATH/custom-paths.sh"

echo "Done!"
