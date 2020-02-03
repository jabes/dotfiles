export ZSH="$HOME/.oh-my-zsh"
export NPM_PACKAGES="$HOME/.npm-global/bin"
export PATH="$HOME/bin:$NPM_PACKAGES:$PATH"

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
	alias pbcopy="xclip -selection clipboard"
	alias pbpaste="xclip -selection clipboard -o"
	alias open="xdg-open"
elif [[ "$OSTYPE" == "darwin"* ]]; then
	alias ls="LC_COLLATE=C ls -CFG"
	alias ll="LC_COLLATE=C ls -lhAFG"
	alias subl="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
fi
