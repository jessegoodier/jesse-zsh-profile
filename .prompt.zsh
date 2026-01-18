
# Set git prompt
ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='
%{$fg[yellow]%}%n%{$reset_color%}@%{$fg[magenta]%}%m%{$reset_color%} in %{$fg_bold[green]%}$PWD%{$reset_color%}$(git_prompt_info)
>'

if [ -f $HOME/.kube/config ] && [ "$(command -v kubectl)" ]; then
PROMPT='
%{$fg[yellow]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}%{$fg[blue]%} %n%{$reset_color%}@%{$fg[magenta]%}%m%{$reset_color%} in %{$fg_bold[green]%}$PWD%{$reset_color%}$(git_prompt_info)
>'
fi