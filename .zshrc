export ZSH="$HOME/.oh-my-zsh"

PATHS=(
    $HOME/bin
    $HOME/.dotfiles/bin
    $HOME/.npm-global/bin
    /usr/local/bin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
)

PATH=$(IFS=:; echo "${PATHS[*]}")
export PATH

ZSH_THEME="robbyrussell"
plugins=(
    git
    git-flow
    zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh
for SCRIPT in $HOME/bin/*.sh; do source $SCRIPT; done

alias ..="cd .."

if [[ "$OSTYPE" == "linux-gnu" ]]; then
	alias ls="LC_COLLATE=C ls --format=vertical --classify --color"
	alias ll="LC_COLLATE=C ls --format=long --human-readable --almost-all --classify --color"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	alias ls="LC_COLLATE=C ls -CFG"
	alias ll="LC_COLLATE=C ls -lhAFG"
fi
