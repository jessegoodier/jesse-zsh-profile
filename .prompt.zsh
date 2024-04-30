# seperate file for the prompt, sourced from .zshrc
# show color options:
# spectrum_ls
# spectrum_bls

# human readable colors:
BOLD_PURPLE="%F{165}"
BRIGHT_GREEN="%F{082}"
DARK_YELLOW="%F{178}"
BLUE="%F{026}"

PROMPT='
%{$fg[yellow]%}%n%{$reset_color%}@%{$fg[magenta]%}%m%{$reset_color%} in %{$fg_bold[green]%}$PWD%{$reset_color%}$(git_prompt_info)
>'

if [ "$(command -v kubectl)" ]; then
PROMPT='
($LIGHT_BLUE$ZSH_KUBECTL_PROMPT%{$reset_color%})$DARK_YELLOW %n%{$reset_color%}@$BOLD_PURPLE%m%{$reset_color%} in $BRIGHT_GREEN$PWD%{$reset_color%}$(git_prompt_info)
>'
fi

