#!/usr/bin/env bash

REPO_URL="git@github.com:jabes/dotfiles.git"
INSTALL_PATH="$HOME/.dotfiles"
LOCAL_BIN_SCRIPTS_PATH="$HOME/bin/scripts"
ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

function run_process_in_background() {
  local CMD_STRING="$2"
  local PID
  PID=$(
    nohup sh -c "$CMD_STRING" >/dev/null 2>&1 &
    echo $!
  )
  while ps -p "$PID" >/dev/null 2>&1; do
    echo -n "."
    sleep 1
  done
}

function multi_arch_install() {
  local PACKAGE="$1"
  if hash "$PACKAGE" 2>/dev/null; then
    echo "Package '$PACKAGE' is already installed."
  else
    if [[ "$OSTYPE" == 'linux-gnu' ]]; then
      echo -n "Installing '$PACKAGE' package..."
      if hash "apt" 2>/dev/null; then run_process_in_background "sudo apt install --assume-yes $PACKAGE"
      elif hash "pacman" 2>/dev/null; then run_process_in_background "sudo pacman --noconfirm --sync $PACKAGE"
      else
        echo
        echo "Unable to install package '$PACKAGE', aborting."
        exit
      fi
      echo "Done"
    elif [[ "$OSTYPE" == 'darwin'* ]]; then
      if hash "brew" 2>/dev/null; then
        echo -n "Installing '$PACKAGE' package"
        run_process_in_background "brew install $PACKAGE"
        echo "Done"
      else
        echo "Installing Homebrew..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        multi_arch_install "$PACKAGE"
      fi
    fi
  fi
}

function multi_arch_channel_install() {
  local GPG_KEY_URL="$1"
  local GPG_KEY_ID="$2"
  local SOURCE_NAME="$3"
  local SOURCE_REPOSITORY_URL="$4"
  local SOURCE_DISTRIBUTION="$5"
  if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    echo -n "Adding '$SOURCE_NAME' repository..."
    if hash "apt" 2>/dev/null; then
      multi_arch_install "apt-transport-https"
      multi_arch_install "ca-certificates"
      curl --fail --silent --show-error --location "$GPG_KEY_URL" | sudo apt-key add -
      echo "deb ${SOURCE_REPOSITORY_URL} apt/${SOURCE_DISTRIBUTION}/" | sudo tee "/etc/apt/sources.list.d/$SOURCE_NAME.list"
      run_process_in_background "sudo apt update"
    elif hash "pacman" 2>/dev/null; then
      curl --fail --silent --show-error --location "$GPG_KEY_URL" | sudo pacman-key --add - && sudo pacman-key --lsign-key "$GPG_KEY_ID"
      echo -e "\n[${SOURCE_NAME}]\nServer = ${SOURCE_REPOSITORY_URL}/arch/${SOURCE_DISTRIBUTION}/$(uname --machine)" | sudo tee --append /etc/pacman.conf
      run_process_in_background "sudo pacman --sync --refresh"
    else
      echo
      echo "Unable to add repository '$SOURCE_REPOSITORY_URL', aborting."
      exit
    fi
    echo "Done"
  fi
}

# Install dependencies
multi_arch_install "curl"
multi_arch_install "git"
multi_arch_install "zsh"
multi_arch_install "vim"
multi_arch_install "diff-so-fancy"

# Install channels
multi_arch_channel_install \
  "https://download.sublimetext.com/sublimehq-pub.gpg" \
  "8A8F901A" \
  "sublime-text" \
  "https://download.sublimetext.com/" \
  "stable"

# Install sublime text
multi_arch_install "sublime-text"

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

GIT_CORE_PAGER="diff-so-fancy | less --tabs=4 -RFX"
if [[ "$(git config --global core.pager)" == "$GIT_CORE_PAGER" ]]; then
  echo "Git is already configured to use good-lookin diffs."
else
  git config --global core.pager "$GIT_CORE_PAGER"
  # Improved colors for the highlighted bits
  git config --global color.ui true
  git config --global color.diff-highlight.oldNormal "red bold"
  git config --global color.diff-highlight.oldHighlight "red bold 52"
  git config --global color.diff-highlight.newNormal "green bold"
  git config --global color.diff-highlight.newHighlight "green bold 22"
  git config --global color.diff.meta "11"
  git config --global color.diff.frag "magenta bold"
  git config --global color.diff.commit "yellow bold"
  git config --global color.diff.old "red bold"
  git config --global color.diff.new "green bold"
  git config --global color.diff.whitespace "red reverse"
fi

echo "All Done!"
