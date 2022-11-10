export PATH=/usr/lib/google-cloud-sdk/bin/:$HOME/.krew/bin:$HOME/bin:/usr/local/bin:$HOME/.local/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/opt/kubernetes-cli@1.22/bin:$PATH

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

ZSH_DISABLE_COMPFIX=true
DISABLE_MAGIC_FUNCTIONS=true
DISABLE_UPDATE_PROMPT=true

ZSH_THEME=""
export ZSH="$HOME/.oh-my-zsh"

zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' insert-unambiguous yes


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

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases

if [ $commands[oc] ]; then
 compdef _oc oc
 source <(oc completion zsh)
fi

if [ $commands[az] ]; then
 if [ -f /usr/share/bash-completion/completions/az ]; then
  source /usr/share/bash-completion/completions/az
 fi
 if [ -f /home/linuxbrew/.linuxbrew/etc/bash_completion.d/az ]; then
  source /home/linuxbrew/.linuxbrew/etc/bash_completion.d/az
 fi
fi
if [ $commands[youtube-dl] ]; then
 source /home/linuxbrew/.linuxbrew/etc/bash_completion.d/youtube-dl.bash-completion
fi

zle -A {.,}history-incremental-search-forward
zle -A {.,}history-incremental-search-backward

# if you have home and end keys that don't work
# bindkey  "^[[1~"  beginning-of-line
# bindkey  "^[[4~"   end-of-line

# change window title when ssh to different host:
function title()
{
   # change the title of the current window or tab
#   echo -ne "\033]0;$*\007"
echo -ne "\e]1;$USER"@"$HOST\a"
}

function ssh()
{
   /usr/bin/ssh "$@"
   # revert the window title after the ssh command
   title $USER"@"$HOST
}

function su()
{
   /bin/su "$@"
   # revert the window title after the su command
   title $USER"@"$HOST
}

ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS

autoload -U colors; colors
autoload -Uz compinit
compinit


PROMPT='
%{$fg[yellow]%}%n%{$reset_color%}@%{$fg[magenta]%}%m%{$reset_color%} in %{$fg_bold[green]%}$PWD%{$reset_color%}$(git_prompt_info)
>'

if [ -x "$(command -v kubectl)" ]; then
PROMPT='
%{$fg[yellow]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}%{$fg[blue]%} %n%{$reset_color%}@%{$fg[magenta]%}%m%{$reset_color%} in %{$fg_bold[green]%}$PWD%{$reset_color%}$(git_prompt_info)
>'
fi

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
