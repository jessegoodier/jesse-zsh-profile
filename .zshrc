# Set PATH
export PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

# Set environment variables
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Set Zsh options
ZSH_DISABLE_COMPFIX=true
DISABLE_MAGIC_FUNCTIONS=true
DISABLE_UPDATE_PROMPT=true

# Set Zsh theme
ZSH_THEME=""
ZSH="$HOME/.oh-my-zsh"

# shell command completion immediately
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' insert-unambiguous yes

# Set plugins
plugins=(
alias-tips
aws
colorize
command-not-found
cp
extract
gcloud
git
helm
httpie
kubectl
sudo
systemadmin
systemd
ubuntu
zsh-autosuggestions
zsh-completions
zsh-kubectl-prompt
zsh-syntax-highlighting
)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Set autocompletion for commands
if (( $+commands[oc] )); then
 compdef _oc oc
 source <(oc completion zsh)
fi

if (( $+commands[az] )); then
 if [ -f /usr/share/bash-completion/completions/az ]; then
  source /usr/share/bash-completion/completions/az
 fi
 if [ -f /home/linuxbrew/.linuxbrew/etc/bash_completion.d/az ]; then
  source /home/linuxbrew/.linuxbrew/etc/bash_completion.d/az
 fi
fi

if (( $+commands[stern] )); then
source <(stern --completion=zsh)
fi

# Set key bindings
zle -A {.,}history-incremental-search-forward
zle -A {.,}history-incremental-search-backward

# Set window title functions
function title()
{
echo -ne "\e]1;$USER"@"$HOST\a"
}

function ssh()
{
   /usr/bin/ssh "$@"
   title $USER"@"$HOST
}

function su()
{
   /bin/su "$@"
   title $USER"@"$HOST
}

# Set git prompt
ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

# Set history options
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST

# Load colors and compinit
autoload -U colors; colors
autoload -Uz compinit

# Check for brew, add functions to FPATH
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Run compinit
compinit


# Source fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# Source aliases and prompt
if [ -f "$HOME/.aliases" ]; then
    source "$HOME/.aliases"
fi
if [ -f "$HOME/.aliases-local" ]; then
    source "$HOME/.aliases-local"
fi
if [ -f "$HOME/.prompt" ]; then
    source "$HOME/.prompt"
fi
