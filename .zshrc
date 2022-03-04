export PATH=$HOME/.local/bin:/usr/local/opt/curl/bin:$PATH

autoload -Uz compinit && compinit && autoload -U colors; colors
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

ZSH_DISABLE_COMPFIX=true

DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_UPDATE_PROMPT=true

ZSH_THEME=""
export ZSH="$HOME/.oh-my-zsh"
# other good ones: yum ubuntu systemd
plugins=(
macos 
gcloud
extract
kubectl
helm
terraform
docker
docker-compose
zsh-autosuggestions
zsh-syntax-highlighting
zsh-kubectl-prompt
alias-tips
brew
git)

source $ZSH/oh-my-zsh.sh
source $HOME/.aliases

#minikube completion broken, need to fix and export to file
#source <(minikube completion zsh)
    
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



# this won't work if you use a omz theme

PROMPT='
%{$fg[yellow]%}%n%{$reset_color%}@%{$fg[magenta]%}%m%{$reset_color%} in %{$fg_bold[green]%}$PWD%{$reset_color%}$(git_prompt_info)
>'

if [ -x "$(command -v kubectl)" ]; then
PROMPT='
%{$fg[blue]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}%{$fg[yellow]%} %n%{$reset_color%}@%{$fg[magenta]%}%m%{$reset_color%} in %{$fg_bold[green]%}$PWD%{$reset_color%}$(git_prompt_info)
>'
fi
