# Set PATH
if ${KREW_ROOT}; then
    export PATH=${KREW_ROOT:-$HOME/.krew}/bin:$PATH
fi
# Detects Homebrew path based on standard install locations
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)" # Apple Silicon Mac
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"    # Intel Mac
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" # Linux
fi
# Set Zsh options
ZSH_DISABLE_COMPFIX=true
DISABLE_MAGIC_FUNCTIONS=true
DISABLE_UPDATE_PROMPT=true
# --- 2. OH MY ZSH SETUP ---
export ZSH="$HOME/.oh-my-zsh"

# Modern Plugins (Requires: brew install zsh-autosuggestions zsh-syntax-highlighting)
# --- 1. PLUGINS ---
plugins=(
    alias-tips
    aws
    colorize
    command-not-found
    cp
    extract
    fzf-tab
    gcloud
    git
    helm
    kubectl
    kubectx
    minikube
    z
    zsh-autosuggestions
    zsh-completions
    zsh-kubectl-prompt
    zsh-syntax-highlighting
)


# --- 3. COMPLETION STYLING ---
# shell command completion immediately
zstyle ':autocomplete:*' min-input 1
# no menu
zstyle ':completion:*' menu no
# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# Insert unambiguous completions immediately
zstyle ':autocomplete:*' insert-unambiguous yes
# Preview directory contents when completing 'cd'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'

source $ZSH/oh-my-zsh.sh


if type brew &>/dev/null; then
    source ${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi

# Set history options
# History File Location
export HISTFILE="$HOME/.zsh_history"

# Zsh-specific History Limits
export HISTSIZE=1000000         # How many lines to keep in active memory
export SAVEHIST=1000000         # How many lines to save in the actual file
# Performance & Behavior
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt INC_APPEND_HISTORY         # Write to the history file immediately, not when the shell exits
setopt SHARE_HISTORY             # Share history between all open terminal sessions (highly recommended)
setopt HIST_EXPIRE_DUPS_FIRST    # If the limit is reached, expire duplicates first
setopt HIST_IGNORE_DUPS          # Don't record an entry if it's just like the last one
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found even if it is a duplicate
setopt HIST_IGNORE_SPACE         # Don't record commands that start with a space (useful for secrets)
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry
unsetopt bang_hist

setopt autocd
setopt extendedglob
setopt NO_menu_complete   # Don't force first match
# setopt auto_menu         # Show menu on second tab
unsetopt flowcontrol     # Free up Ctrl-S and Ctrl-Q
# Set key bindings
zle -A {.,}history-incremental-search-forward
zle -A {.,}history-incremental-search-backward

# This enables CTRL-R (history) and CTRL-T (files)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Source aliases and prompt
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"
[ -f "$HOME/.aliases-local" ] && source "$HOME/.aliases-local"
[ -f "$HOME/.prompt.zsh" ] && source "$HOME/.prompt.zsh"

foreach cmd (kpf ksd); do
  unalias $cmd 2>/dev/null
done
if [ -s "$(command -v kubecolor)" ]; then
  alias kubectl="kubecolor"
  compdef kubecolor=kubectl
  alias watch='KUBECOLOR_FORCE_COLORS=true watch --color '
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
    [[ -f ~/.zsh_macos.zsh ]] && source ~/.zsh_macos.zsh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    [[ -f ~/.zsh_linux.zsh ]] && source ~/.zsh_linux.zsh
fi

alias curl='noglob curl'
export PATH="$HOME/.local/bin:$PATH"
export EDITOR='vim'
export VISUAL='vim'
