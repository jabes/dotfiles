#!/usr/bin/env bash

REPO_URL="git@github.com:jabes/dotfiles.git"
INSTALL_PATH="$HOME/.dotfiles"
LOCAL_BIN_SCRIPTS_PATH="$HOME/bin/scripts"
ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

function multi_arch_install() {
  local PACKAGE="$1"
  if hash "$PACKAGE" 2>/dev/null; then
    echo "Package '$PACKAGE' is already installed."
  else
    if [[ "$OSTYPE" == 'linux-gnu' ]]; then
      if hash "apt" 2>/dev/null; then apt install --assume-yes "$PACKAGE"
      elif hash "pacman" 2>/dev/null; then pacman --noconfirm --sync "$PACKAGE"
      elif hash "pkg" 2>/dev/null; then pkg install --yes "$PACKAGE"
      elif hash "apk" 2>/dev/null; then apk add "$PACKAGE"
      elif hash "yum" 2>/dev/null; then yum install --assumeyes "$PACKAGE"
      else
        echo "Unable to install '$PACKAGE', aborting."
        exit
      fi
    elif [[ "$OSTYPE" == 'darwin'* ]]; then
      if hash "brew" 2>/dev/null; then
        brew install "$PACKAGE"
      else
        echo "Installing Homebrew..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        multi_arch_install "$PACKAGE"
      fi
    fi
  fi
}

# Install dependencies
multi_arch_install "git"
multi_arch_install "zsh"
multi_arch_install "vim"

if [[ -d "$INSTALL_PATH" ]]; then
  echo "Dotfiles repo is already cloned."
else
  echo "Cloning Dotfiles repo..."
  git clone --recurse-submodules -j8 "$REPO_URL" "$INSTALL_PATH"
fi

echo -n "Linking files..."
ln -s -f "$INSTALL_PATH/.npmrc" "$HOME/.npmrc"
ln -s -f "$INSTALL_PATH/.zshrc" "$HOME/.zshrc"
ln -s -f "$INSTALL_PATH/submodules/timelapse-deflicker/timelapse-deflicker.pl" "$INSTALL_PATH/bin/scripts/timelapse-deflicker.pl"
echo "Done"

echo -n "Looking for sublime..."
if [[ "$OSTYPE" == 'linux-gnu' ]]; then SUBL_PATH=$(command -v subl3)
elif [[ "$OSTYPE" == 'darwin'* ]]; then SUBL_PATH=$(find /Applications -type f -name subl); fi
echo "Done"

if [[ -z "$SUBL_PATH" ]]; then
  echo "Could not link sublime because it was not found."
else
  echo -n "Linking sublime..."
  ln -s -f "$SUBL_PATH" "$HOME/bin/subl"
  echo "Done"
fi

if [[ -d "$ZSH" ]]; then
  echo "Oh My Zsh is already installed."
else
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "ZSH Autosuggestions plugin is already installed."
else
  echo "Installing ZSH Autosuggestions plugin..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ -d "$HOME/.vim_runtime" ]]; then
  echo "Vim configuration is already installed."
else
  echo "Installing Vim configuration..."
  git clone --depth=1 https://github.com/amix/vimrc.git "$HOME/.vim_runtime"
  sh "$HOME/.vim_runtime/install_awesome_vimrc.sh"
fi

if [[ -f "$LOCAL_BIN_SCRIPTS_PATH/custom-paths.sh" ]]; then
  echo "Custom paths is already installed."
else
  echo "Creating custom paths..."
  mkdir -p "$LOCAL_BIN_SCRIPTS_PATH"
  cp "$INSTALL_PATH/custom-paths.sh" "$LOCAL_BIN_SCRIPTS_PATH/custom-paths.sh"
fi

echo "All Done!"
