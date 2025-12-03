# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"


# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load compinit function early
autoload -Uz compinit

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# Initialize completion system
compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.alias nv='nvim'
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Alias:
alias nv='nvim'
alias ls='ls --color'
alias ..='cd ..'
alias reload='source ~/.zshrc'
alias parrot='curl ascii.live/parrot'
alias edit='nv ~/.zshrc'
alias cls='clear ; ls'
alias python='python3'
alias free='free -h'
alias mkdir='mkcd'
alias rm='rm -ri'
alias df='df  -h'
alias du='du -h'
alias ps='ps -aux'
alias grep='grep --color=auto'
alias neo='cls && fastfetch'
alias py='python'
alias cat='lolcat'
alias nvkeys='nv ~/.config/nvim/lua/config/keymaps.lua'

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Shell integrations
# Ensure ~/.local/bin is in PATH (for zoxide and other user-installed tools)
export PATH="$HOME/.local/bin:$PATH"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zoxide init --cmd cd zsh)"

# Built-ins Redifining
mkcd(){command mkdir -p -- "$1" && cd "$1";}
chpwd(){ls}

# Run fastfetch on shell startup
clear && fastfetch
