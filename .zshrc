# Set PATH
export PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/linuxbrew/.local/bin:${KREW_ROOT:-$HOME/.krew}/bin:$PATH

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
kubectl
zsh-autosuggestions
zsh-completions
zsh-kubectl-prompt
zsh-syntax-highlighting
)

# other plugins : httpie
# sudo
# systemadmin
# systemd
# ubuntu

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh


# more command completions

[ "$(command -v brew)" &>/dev/null ] && [ -f "$(brew --prefix)/etc/bash_completion.d/az" &>/dev/null ] && autoload -U +X bashcompinit && bashcompinit && \. "$(brew --prefix)/etc/bash_completion.d/az"

[ "$(command -v stern)" ] && source <(stern --completion=zsh)

if [ -s "$(command -v kubecolor)" ]; then
  alias kubectl="kubecolor"
  compdef kubecolor=kubectl
  alias watch='KUBECOLOR_FORCE_COLORS=true watch --color '
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
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"
[ -f "$HOME/.aliases-local" ] && source "$HOME/.aliases-local"
[ -f "$HOME/.kube-scripts/aliases.sh" ] && source "$HOME/.kube-scripts/aliases.sh"
[ -f "$HOME/.prompt.zsh" ] && source "$HOME/.prompt.zsh"
[ -f "$HOME/.alias-help" ] && source "$HOME/.alias-help"
unalias ksd
unalias kpf
