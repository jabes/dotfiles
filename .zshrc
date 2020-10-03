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
ZSH_DISABLE_COMPFIX="true"

plugins=(
    git
    git-flow
    zsh-autosuggestions
)

SCRIPT_PATHS=(
    $ZSH
    $HOME/.dotfiles/bin/scripts
    $HOME/bin/scripts
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

# http://zsh.sourceforge.net/Doc/Release/Options.html
setopt rm_star_silent
unsetopt nomatch
