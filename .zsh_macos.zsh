export PATH=$HOME/git/kubecost-cost-model/bin:$HOME/bin:$HOME/.local/bin:${KREW_ROOT:-$HOME/.krew}/bin:$PATH
PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""
HYPHEN_INSENSITIVE="true"



ZSH_THEME_GIT_PROMPT_PREFIX=" on %{$fg[magenta]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[green]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

gcp-login-sre() {
gcloud iam workforce-pools create-login-config \
  locations/global/workforcePools/kubecost-sre/providers/ibm-w3id-sre \
  --output-file=/tmp/gcp_sre_login_config.json
gcloud auth login --activate --login-config=/tmp/gcp_sre_login_config.json
}
gcp-login-guestbook() {
gcloud iam workforce-pools create-login-config \
  locations/global/workforcePools/kubecost-access/providers/ibm-w3id \
  --output-file=/tmp/gcp_guestbook_login_config.json
gcloud auth login --activate --login-config=/tmp/gcp_guestbook_login_config.json
}
gcp-login-owner() {
gcloud iam workforce-pools create-login-config \
  locations/global/workforcePools/kubecost-owners/providers/ibm-w3id-owners \
  --output-file=/tmp/gcp_owner_login_config.json
gcloud auth login --activate --login-config=/tmp/gcp_owner_login_config.json
}

for alias_name in kpf ksd; do
  unalias "$alias_name" 2>/dev/null
done

alias less='bat -p'

