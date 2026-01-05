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
    z
    zsh-autosuggestions
    zsh-completions
    zsh-kubectl-prompt
    zsh-syntax-highlighting
)

# --- 2. FZF INITIALIZATION ---
# This enables CTRL-R (history) and CTRL-T (files)
source <(fzf --zsh)

# --- 3. COMPLETION STYLING ---
# shell command completion immediately
# no menu
zstyle ':completion:*' menu no
# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# Insert unambiguous completions immediately
zstyle ':autocomplete:*' insert-unambiguous yes
# Preview directory contents when completing 'cd'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'

source $ZSH/oh-my-zsh.sh

# --- 3. MODERN COMPLETION SETTINGS ---
setopt autocd
setopt extendedglob
# setopt NO_menu_complete   # Don't force first match
setopt auto_menu         # Show menu on second tab
unsetopt flowcontrol     # Free up Ctrl-S and Ctrl-Q

if [ -s "$(command -v kubecolor)" ]; then
  alias kubectl="kubecolor"
  compdef kubecolor=kubectl
  alias watch='KUBECOLOR_FORCE_COLORS=true watch --color '
fi

# Set key bindings
zle -A {.,}history-incremental-search-forward
zle -A {.,}history-incremental-search-backward

if type brew &>/dev/null; then
    source ${HOMEBREW_PREFIX}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source ${HOMEBREW_PREFIX}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi
# --- 4. OS-SPECIFIC LOADING ---
if [[ "$OSTYPE" == "darwin"* ]]; then
    [[ -f ~/.zsh_macos.zsh ]] && source ~/.zsh_macos.zsh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    [[ -f ~/.zsh_linux.zsh ]] && source ~/.zsh_linux.zsh
fi


# Set history options
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
# Source fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Source aliases and prompt
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"
[ -f "$HOME/.aliases-local" ] && source "$HOME/.aliases-local"
[ -f "$HOME/.kube-scripts/aliases.sh" ] && source "$HOME/.kube-scripts/aliases.sh"
[ -f "$HOME/.prompt.zsh" ] && source "$HOME/.prompt.zsh"
[ -f "$HOME/.alias-help" ] && source "$HOME/.alias-help"
unalias ksd 2>/dev/null
unalias kpf 2>/dev/null