FROM ubuntu:latest
USER 0
RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-utils build-essential procps curl wget file git \
  apt-transport-https vim lsb-release unzip less \
  ca-certificates locales openssh-client \
  patch sudo uuid-runtime zsh \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}

RUN sed -i 's/ALL=(ALL:ALL) ALL/ALL=(ALL:ALL) NOPASSWD:ALL/g' /etc/sudoers
USER ubuntu
WORKDIR /home/ubuntu

COPY .aliases-local Brewfile $HOME/
COPY pip.conf $HOME/.config/pip/pip.conf

RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
  && /home/linuxbrew/.linuxbrew/bin/brew install gcc \
  && /home/linuxbrew/.linuxbrew/bin/brew bundle --file $HOME/Brewfile \
  && /home/linuxbrew/.linuxbrew/bin/brew cleanup \
  && /home/linuxbrew/.linuxbrew/bin/pip3 install boto3 s3-browser requests

# # RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
# #  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
# #  && apt-get update && sudo apt-get -y install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
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
 && sed -i "s/alias ksd/#  alias ksd/" ~/.oh-my-zsh/plugins/kubectl/kubectl.plugin.zsh \
 && sudo chown -R ubuntu: /home/ubuntu \
 && sudo chsh -s /bin/zsh ubuntu

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"