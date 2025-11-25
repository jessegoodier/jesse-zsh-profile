#!/usr/bin/env bash
set -euo pipefail

# Detect if running as root
if [[ "$EUID" -ne 0 ]]; then
    # check for sudo 
    if command -v sudo >/dev/null 2>&1; then
    echo "sudo is installed"
    else
        echo "sudo is NOT installed and you are not root"
        exit 1
    fi
    SUDO="$SUDO"
else
    SUDO=""
fi

echo "tzdata tzdata/Areas select America" | $SUDO debconf-set-selections
echo "tzdata tzdata/Zones/America select Detroit" | $SUDO debconf-set-selections
$SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

$SUDO apt-get update \
  && $SUDO apt-get install -y --no-install-recommends software-properties-common \
  && $SUDO apt-get update \
  && $SUDO apt-get install -y --no-install-recommends \
  apt-utils build-essential procps curl wget file git uidmap \
  apt-transport-https vim lsb-release unzip less \
  ca-certificates locales openssh-client \
  patch $SUDO uuid-runtime zsh \
  && $SUDO rm -rf /var/lib/apt/lists/* \
  && $SUDO apt-get clean autoclean \
  && $SUDO apt-get autoremove --yes \
  && $SUDO rm -rf /var/lib/{apt,dpkg,cache,log}

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
  && /home/linuxbrew/.linuxbrew/bin/brew install gcc \
  && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/Brewfile-ubuntu \
  && /home/linuxbrew/.linuxbrew/bin/brew bundle --file $HOME/Brewfile-ubuntu \
  && /home/linuxbrew/.linuxbrew/bin/brew cleanup

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
 && git clone https://github.com/djui/alias-tips.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/alias-tips \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
 && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
 && git clone https://github.com/superbrothers/zsh-kubectl-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt \
 && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.zshrc -O $HOME/.zshrc \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.vimrc -O $HOME/.vimrc \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.prompt.zsh -O $HOME/.prompt.zsh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.aliases -O $HOME/.aliases \
 && mkdir -p ~/.kube-scripts \
 && wget https://raw.githubusercontent.com/jessegoodier/kgc/main/kgc.sh -O $HOME/.kube-scripts/kgc.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/aliases.sh -O $HOME/.kube-scripts/aliases.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/get-all-aks-clusters.sh -O $HOME/.kube-scripts/get-all-aks-clusters.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/get-all-eks-clusters.sh -O $HOME/.kube-scripts/get-all-eks-clusters.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/get-all-gke-clusters.sh -O $HOME/.kube-scripts/get-all-gke-clusters.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/k-get-all-pod-images.sh -O $HOME/.kube-scripts/k-get-all-pod-images.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/k-remove-bad-contexts.sh -O $HOME/.kube-scripts/k-remove-bad-contexts.sh \
 && sed -i "s/alias ksd/#  alias ksd/" ~/.oh-my-zsh/plugins/kubectl/kubectl.plugin.zsh

$SUDO chsh -s /usr/bin/zsh $USER

# wget "https://get.docker.com/" -O get-docker.sh
# sh get-docker.sh
# dockerd-rootless-setuptool.sh install
