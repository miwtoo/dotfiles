export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

ENABLE_CORRECTION="true"

# plugins=(git)

source $ZSH/oh-my-zsh.sh

# source antidote
source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
antidote load

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# thefuck
eval $(thefuck --alias)
eval "$(starship init zsh)"