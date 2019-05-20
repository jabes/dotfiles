export ZSH="$HOME/.oh-my-zsh"
export EDITOR="subl"
export VISUAL="vim"
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

alias ll="LC_COLLATE=C ls -lhA --color"
alias ls="ls -CF"
alias ..="cd .."
alias open="xdg-open"
alias subl="subl3"
alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"
alias diff="colordiff"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/opt/google-cloud-sdk/path.zsh.inc' ]; then source '/opt/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/opt/google-cloud-sdk/completion.zsh.inc' ]; then source '/opt/google-cloud-sdk/completion.zsh.inc'; fi
