#!/usr/bin/env bash

REPO_URL="https://github.com/jabes/dotfiles.git"
INSTALL_PATH="$HOME/.dotfiles"
LOCAL_BIN_SCRIPTS_PATH="$HOME/bin/scripts"
ZSH="$HOME/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

function abort() {
  exit 1
}

function is_empty() {
  if [[ -z "$1" ]]; then return 0; else return 1; fi
}

function is_not_empty() {
  if [[ -n "$1" ]]; then return 0; else return 1; fi
}

function wait_for_process_to_finish() {
  local PID="$1"
  while ps -p "$PID" 1>/dev/null; do
    echo -n "."
    sleep 1
  done
}

function run_process_in_background() {
  local CMD_STRING="$1"
  nohup sh -c "$CMD_STRING" 1>/dev/null 2>&1 &
  wait_for_process_to_finish "$!"
}

function download() {
  local URL="$1"
  local OUTPUT="$2"
  # Define output path if not specified
  if is_empty "$OUTPUT"; then
    OUTPUT="$(mktemp -d)/$(basename "$URL")"
  fi
  # Download file to defined output path
  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --output "$OUTPUT" \
    "$URL"
  # Return output path
  echo "$OUTPUT"
}

function download_and_run() {
  run_process_in_background "sh $(download "$1")"
}

function is_brew_package_cask() {
  is_not_empty "$(brew cask info "$1" 2>/dev/null)"
}

function is_brew_package_formula() {
  is_not_empty "$(brew info --json "$1" 2>/dev/null)"
}

function is_brew_cask_installed() {
  is_not_empty "$(brew cask list | grep "$1")"
}

function is_brew_formula_installed() {
  is_not_empty "$(brew list | grep "$1")"
}

function is_npm_package_installed() {
  is_not_empty "$(npm list --global | grep "$1")"
}

function is_apt_package_installed() {
  is_not_empty "$(apt list --installed | grep "$1")"
}

function is_pacman_package_installed() {
  is_not_empty "$(pacman --query | grep "$1")"
}

function brew_install_cask() {
  local PACKAGE="$1"
  if is_brew_cask_installed "$PACKAGE"; then
    echo "Brew cask '$PACKAGE' is already installed."
  else
    echo -n "Installing brew cask '$PACKAGE' now..."
    run_process_in_background "brew cask install $PACKAGE"
    if is_brew_cask_installed "$PACKAGE"; then
      echo "Success"
    else
      echo
      echo "Failed to install cask, aborting."
      abort
    fi
  fi
}

function brew_install_formula() {
  local PACKAGE="$1"
  if is_brew_formula_installed "$PACKAGE"; then
    echo "Brew formula '$PACKAGE' is already installed."
  else
    echo -n "Installing brew formula '$PACKAGE' now..."
    run_process_in_background "brew install $PACKAGE"
    if is_brew_formula_installed "$PACKAGE"; then
      echo "Success"
    else
      echo
      echo "Failed to install formula, aborting."
      abort
    fi
  fi
}

function brew_install() {
  local PACKAGE="$1"
  if hash "brew" 2>/dev/null; then
    if is_brew_package_formula "$PACKAGE"; then
      brew_install_formula "$PACKAGE"
    elif is_brew_package_cask "$PACKAGE"; then
      brew_install_cask "$PACKAGE"
    else
      echo "Could not find package '$PACKAGE' in brew repo, aborting."
      abort
    fi
  else
    echo -n "Installing Homebrew..."
    download_and_run https://raw.githubusercontent.com/Homebrew/install/master/install.sh
    echo "Done"
    brew_install "$PACKAGE"
  fi
}

function npm_install_global_package() {
  local PACKAGE="$1"
  if is_npm_package_installed "$PACKAGE"; then
    echo "NPM already has '$PACKAGE' installed."
  else
    echo -n "Installing '$PACKAGE' as global NPM package..."
    run_process_in_background "npm install --global $PACKAGE"
    if is_npm_package_installed "$PACKAGE"; then
      echo "Success"
    else
      echo
      echo "Failed to install package, aborting."
      abort
    fi
  fi
}

function install_apt_package() {
  local PACKAGE="$1"
  if is_apt_package_installed "$PACKAGE"; then
    echo "Package '$PACKAGE' is already installed."
  else
    echo -n "Installing apt package '$PACKAGE' now..."
    run_sudo_process_in_background "apt install --assume-yes $PACKAGE"
    if is_apt_package_installed "$PACKAGE"; then
      echo "Success"
    else
      echo
      echo "Failed to install package, aborting."
      abort
    fi
  fi
}

function install_pacman_package() {
  local PACKAGE="$1"
  if is_pacman_package_installed "$PACKAGE"; then
    echo "Package '$PACKAGE' is already installed."
  else
    echo -n "Installing pacman package '$PACKAGE' now..."
    run_sudo_process_in_background "pacman --noconfirm --sync $PACKAGE"
    if is_pacman_package_installed "$PACKAGE"; then
      echo "Success"
    else
      echo
      echo "Failed to install package, aborting."
      abort
    fi
  fi
}

function multi_arch_update() {
  echo -n "Updating package sources..."
  if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    if hash "apt" 2>/dev/null; then
      run_sudo_process_in_background "apt update --assume-yes"
    elif hash "pacman" 2>/dev/null; then
      run_sudo_process_in_background "pacman --noconfirm --sync --refresh"
    else
      echo
      echo "Unrecognized package manager, aborting."
      abort
    fi
  elif [[ "$OSTYPE" == 'darwin'* ]]; then
    run_process_in_background "brew update"
  fi
  echo "Success"
}

function multi_arch_install() {
  local PACKAGE="$1"
  if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    if hash "apt" 2>/dev/null; then
      install_apt_package "$PACKAGE"
    elif hash "pacman" 2>/dev/null; then
      install_pacman_package "$PACKAGE"
    fi
  elif [[ "$OSTYPE" == 'darwin'* ]]; then
    brew_install "$PACKAGE"
  fi
}

function multi_arch_channel_install() {
  local GPG_KEY_URL="$1"
  local GPG_KEY_ID="$2"
  local SOURCE_NAME="$3"
  local SOURCE_REPOSITORY_URL="$4"
  local SOURCE_DISTRIBUTION="$5"
  if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    if hash "apt" 2>/dev/null; then
      multi_arch_install "apt-transport-https"
      multi_arch_install "ca-certificates"
      local SOURCE_FILE="/etc/apt/sources.list.d/$SOURCE_NAME.list"
      local GPG_KEY_FILE="/etc/apt/trusted.gpg.d/$SOURCE_NAME.gpg"
      if [[ -f "$SOURCE_FILE" ]]; then
        echo "Repository '$SOURCE_NAME' is already added."
      else
        echo -n "Adding repository '$SOURCE_NAME' now..."
        gpg --dearmor <"$(download "$GPG_KEY_URL")" | sudo tee "$GPG_KEY_FILE" 1>/dev/null
        echo "deb ${SOURCE_REPOSITORY_URL}/ apt/${SOURCE_DISTRIBUTION}/" | sudo tee "$SOURCE_FILE" 1>/dev/null
        echo "Success"
        multi_arch_update
      fi
    elif hash "pacman" 2>/dev/null; then
      if grep --quiet "$SOURCE_NAME" /etc/pacman.conf; then
        echo "Repository '$SOURCE_NAME' is already added."
      else
        echo -n "Adding repository '$SOURCE_NAME' now..."
        sudo pacman-key --add "$(download "$GPG_KEY_URL")" 1>/dev/null 2>&1
        sudo pacman-key --lsign-key "$GPG_KEY_ID" 1>/dev/null 2>&1
        echo -e "\n[${SOURCE_NAME}]\nServer = ${SOURCE_REPOSITORY_URL}/arch/${SOURCE_DISTRIBUTION}/$(uname --machine)" | sudo tee --append /etc/pacman.conf 1>/dev/null
        echo "Success"
        multi_arch_update
      fi
    else
      echo
      echo "Unable to add repository '$SOURCE_NAME' due to unrecognized system architecture, aborting."
      abort
    fi
  fi
}

function initiate_sudo_privileges() {
  local CAN_RUN_SUDO
  CAN_RUN_SUDO=$(sudo -n uptime 2>&1 | grep -c "load")
  if [[ "$CAN_RUN_SUDO" -gt 0 ]]; then
    "Sudo privileges already granted."
  else
    set -e
    stty -echo
    read -r -s -p "Give me your password: " PASSWORD
    # -S : read the password from the standard input
    # -p : override the default password prompt
    echo "$PASSWORD" | sudo -S -p '' echo "Your password is mine now!"
    unset PASSWORD
    stty echo
    set +e
  fi
}

function add_user_to_sudoers() {
  echo -n "Adding user '$USER' to sudoers..."
  echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$USER" 1>/dev/null
  echo "Done"
}

# Initiate sudo privs
initiate_sudo_privileges

# Add user to sudoers
add_user_to_sudoers

# Install dependencies
multi_arch_update
multi_arch_install "curl"
multi_arch_install "git"
multi_arch_install "zsh"
multi_arch_install "vim"
multi_arch_install "nodejs"

# Ensure that NPM was installed
if hash "npm" 2>/dev/null; then
  echo "NPM was found! Thanks Node.js :)"
else
  echo "Hmm.. Node.js was installed but NPM is nowhere to be found."
  multi_arch_install "npm"
fi

# Install sublime text channel
multi_arch_channel_install \
  "https://download.sublimetext.com/sublimehq-pub.gpg" \
  "8A8F901A" \
  "sublime-text" \
  "https://download.sublimetext.com" \
  "stable"

# Install sublime text package
multi_arch_install "sublime-text"

if [[ -d "$INSTALL_PATH" ]]; then
  echo "Dotfiles repo is already cloned."
else
  echo -n "Cloning Dotfiles repo..."
  git clone --quiet --recurse-submodules -j8 "$REPO_URL" "$INSTALL_PATH"
  echo "Done"
fi

# Copy custom paths script to user bin directory
if [[ -f "$LOCAL_BIN_SCRIPTS_PATH/custom-paths.sh" ]]; then
  echo "Custom paths is already installed."
else
  echo -n "Creating custom paths..."
  mkdir -p "$LOCAL_BIN_SCRIPTS_PATH"
  cp "$INSTALL_PATH/custom-paths.sh" "$LOCAL_BIN_SCRIPTS_PATH/custom-paths.sh"
  echo "Done"
fi

# Link dotfiles to user home directory
echo -n "Linking files..."
ln -s -f "$INSTALL_PATH/.npmrc" "$HOME/.npmrc"
ln -s -f "$INSTALL_PATH/.zshrc" "$HOME/.zshrc"
ln -s -f \
  "$INSTALL_PATH/submodules/timelapse-deflicker/timelapse-deflicker.pl" \
  "$LOCAL_BIN_SCRIPTS_PATH/timelapse-deflicker.pl"
echo "Done"

# Link sublime on OSX
if [[ "$OSTYPE" == 'darwin'* ]]; then
  echo -n "Looking for sublime..."
  SUBL_PATH=$(find /Applications -type f -name subl)
  echo "Done"
  if [[ -z "$SUBL_PATH" ]]; then
    echo "Could not link sublime because it was not found."
  else
    echo -n "Linking sublime..."
    ln -s -f "$SUBL_PATH" "$HOME/bin/subl"
    echo "Done"
  fi
fi

# Install Oh My Zsh
if [[ -d "$ZSH" ]]; then
  echo "Oh My Zsh is already installed."
else
  echo -n "Installing Oh My Zsh..."
  export CHSH=no
  export RUNZSH=no
  export KEEP_ZSHRC=yes
  download_and_run https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  echo "Success"
fi

# Install ZSH Autosuggestions Plugin
if [[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
  echo "ZSH Autosuggestions plugin is already installed."
else
  echo -n "Installing ZSH Autosuggestions plugin..."
  git clone --depth=1 --quiet https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  echo "Success"
fi

# Install Vim configuration
if [[ -d "$HOME/.vim_runtime" ]]; then
  echo "Vim configuration is already installed."
else
  echo -n "Installing Vim configuration..."
  git clone --depth=1 --quiet https://github.com/amix/vimrc.git "$HOME/.vim_runtime"
  sh "$HOME/.vim_runtime/install_awesome_vimrc.sh" 1>/dev/null
  echo "Success"
fi

# Install GNU utils on OSX
# These also get aliased in bin/scripts/gnu-utils-alias.sh
if [[ "$OSTYPE" == 'darwin'* ]]; then
  brew_install "coreutils"
fi

# Install diff-so-fancy and configure git to use it by default for diffs
npm_install_global_package "diff-so-fancy"
GIT_CORE_PAGER="diff-so-fancy | less --tabs=4 -RFX"
if [[ "$(git config --global core.pager)" == "$GIT_CORE_PAGER" ]]; then
  echo "Git is already configured to use good-lookin diffs."
else
  echo -n "Configuring git to use diff-so-fancy by default..."
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
  echo "Done"
fi

# All Done!
echo "All Done!"

# Change shell
if [[ "$(basename "$SHELL")" != "zsh" ]]; then
  SHELL="$(command -v zsh)"
  export SHELL="$SHELL"
  chsh -s "$SHELL"
  exec zsh --login
fi
