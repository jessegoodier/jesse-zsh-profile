# Disable the aws plugin's default RPROMPT display
SHOW_AWS_PROMPT=false
# Function to show AWS_PROFILE if it's not "default" or empty
function aws_profile_info() {
  if [[ -n "$AWS_PROFILE" && "$AWS_PROFILE" != "default" ]]; then
    echo "%{$fg[cyan]%} $AWS_PROFILE %{$reset_color%}"
  fi
}
RPROMPT=""
PROMPT='$(aws_profile_info)%{$fg[yellow]%}($ZSH_KUBECTL_PROMPT)%{$reset_color%}%{$fg[blue]%} %n%{$reset_color%}@%{$fg[magenta]%}%m%{$reset_color%} in %{$fg_bold[green]%}$PWD%{$reset_color%}$(git_prompt_info)
>'
