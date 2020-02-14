PATHS=(
    $HOME/bin
    $HOME/.dotfiles/bin
    /usr/local/bin
    /usr/local/sbin
    /usr/bin
    /usr/sbin
    /bin
    /sbin
)

export PATH=$(IFS=:; echo "${PATHS[*]}")
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(
    git
    git-flow
    zsh-autosuggestions
)

SCRIPT_PATHS=(
    $ZSH
    $HOME/bin/scripts
    $HOME/.dotfiles/bin/scripts
)

for SCRIPT_PATH in "${SCRIPT_PATHS[@]}"; do
    if [[ -d "$SCRIPT_PATH" ]]; then
        for SCRIPT in $SCRIPT_PATH/*; do
            if [[ -f "$SCRIPT" && $SCRIPT == *.sh ]]; then
                source $SCRIPT
            fi
        done
    fi
done

alias ..="cd .."

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    alias ls="LC_COLLATE=C ls --format=vertical --classify --color"
    alias ll="LC_COLLATE=C ls --format=long --human-readable --almost-all --classify --color"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias ls="LC_COLLATE=C ls -CFG"
    alias ll="LC_COLLATE=C ls -lhAFG"
fi
