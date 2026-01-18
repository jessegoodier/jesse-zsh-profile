# --- 1. ENVIRONMENT & PATHS ---
# Detect Homebrew early so we can use $(brew --prefix)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Set PATHs
export PATH="$HOME/.local/bin:$PATH"
# Krew (Kubernetes plugins)
export KREW_ROOT="${KREW_ROOT:-$HOME/.krew}"
[[ -d "${KREW_ROOT}/bin" ]] && export PATH="${KREW_ROOT}/bin:$PATH"

export EDITOR='vim'
export VISUAL='vim'

# --- 2. OH MY ZSH CONFIGURATION ---
export ZSH="$HOME/.oh-my-zsh"

# OMZ behavior flags (Must be set BEFORE sourcing OMZ)
ZSH_DISABLE_COMPFIX=true
DISABLE_MAGIC_FUNCTIONS=true
DISABLE_UPDATE_PROMPT=true

# Add Homebrew zsh-completions to FPATH before OMZ calls compinit
if type brew &>/dev/null; then
    FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
fi

# Plugin List
plugins=(
    alias-tips aws colorize command-not-found cp extract
    fzf-tab gcloud git helm kubectl kubectx minikube z
    zsh-completions zsh-kubectl-prompt
)

# --- 3. SOURCE OH MY ZSH ---
# This initializes completions and the plugin system
source $ZSH/oh-my-zsh.sh

# --- 4. MANUAL PLUGIN SOURCING (Brew Versions) ---
# Better to source these after OMZ to ensure they highlight correctly
if type brew &>/dev/null; then
    source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# --- 5. COMPLETION & ZSTYLE ---
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# preview command output (e.g. for kill)
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
# preview environment variables
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
	fzf-preview 'echo ${(P)word}'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# --- 6. HISTORY SETTINGS (Optimized for 1B lines) ---
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

# --- 7. SHELL OPTIONS & KEYBINDINGS ---
setopt autocd
setopt extendedglob
setopt NO_menu_complete
unsetopt flowcontrol

# Key bindings
zle -A {.,}history-incremental-search-forward
zle -A {.,}history-incremental-search-backward

# FZF initialization (enables Ctrl+R history search and Ctrl+T file search)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- 8. ALIASES & CUSTOM FUNCTIONS ---
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"
[ -f "$HOME/.aliases-local" ] && source "$HOME/.aliases-local"
[ -f "$HOME/.prompt.zsh" ] && source "$HOME/.prompt.zsh"

# Clean up conflicting aliases from plugins
for cmd in kpf ksd; do
  unalias $cmd 2>/dev/null
done

# Kubernetes Tooling
if (( $+commands[kubecolor] )); then
  alias kubectl="kubecolor"
  compdef _kubectl kubecolor  # Corrected compdef syntax
  alias watch='KUBECOLOR_FORCE_COLORS=true watch --color '
fi

alias curl='noglob curl'

# --- 9. OS SPECIFIC CONFIGS ---
if [[ "$OSTYPE" == "darwin"* ]]; then
    [[ -f ~/.zsh_macos.zsh ]] && source ~/.zsh_macos.zsh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    [[ -f ~/.zsh_linux.zsh ]] && source ~/.zsh_linux.zsh
fi
