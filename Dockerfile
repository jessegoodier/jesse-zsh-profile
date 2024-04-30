FROM ubuntu:latest
USER 0
RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-utils build-essential procps curl wget file git \
  apt-transport-https vim lsb-release unzip less \
  ca-certificates locales openssh-client \
  patch sudo uuid-runtime zsh

RUN useradd -m -s /bin/zsh linuxbrew && \
  usermod -aG sudo linuxbrew &&  \
  mkdir -p /home/linuxbrew/.linuxbrew && \
  chown -R linuxbrew: /home/linuxbrew/.linuxbrew \
  && echo "linuxbrew ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/linuxbrew \
  && echo "ALL ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/nopasswd
USER linuxbrew
WORKDIR /home/linuxbrew

COPY Brewfile /home/linuxbrew/
COPY pip.conf /home/linuxbrew/.config/pip/pip.conf
COPY .aliases-local /home/linuxbrew/.aliases-local

RUN sudo chown -R linuxbrew:linuxbrew /home/linuxbrew \
  && NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
  && /home/linuxbrew/.linuxbrew/bin/brew install gcc \
  && /home/linuxbrew/.linuxbrew/bin/brew bundle --file /home/linuxbrew/Brewfile \
  && /home/linuxbrew/.linuxbrew/bin/brew cleanup \
  && /home/linuxbrew/.linuxbrew/bin/pip3 install boto3 s3-browser requests

# RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
#  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
#  && apt-get update && sudo apt-get -y install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
 && git clone https://github.com/djui/alias-tips.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/alias-tips \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
 && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
 && git clone https://github.com/superbrothers/zsh-kubectl-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt \
 && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.zshrc -O ~/.zshrc \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.vimrc -O ~/.vimrc \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.prompt -O ~/.prompt \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.aliases -O ~/.aliases \
 && mkdir -p ~/.kube-scripts \
 && wget https://raw.githubusercontent.com/jessegoodier/kgc/main/kgc.sh -O ~/.kube-scripts/kgc.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/aliases.sh -O ~/.kube-scripts/aliases.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/get-all-aks-clusters.sh -O ~/.kube-scripts/get-all-aks-clusters.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/get-all-eks-clusters.sh -O ~/.kube-scripts/get-all-eks-clusters.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/get-all-gke-clusters.sh -O ~/.kube-scripts/get-all-gke-clusters.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/k-get-all-pod-images.sh -O ~/.kube-scripts/k-get-all-pod-images.sh \
 && wget https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kube-scripts/k-remove-bad-contexts.sh -O ~/.kube-scripts/k-remove-bad-contexts.sh \
 && sed -i "s/alias ksd/#  alias ksd/" ~/.oh-my-zsh/plugins/kubectl/kubectl.plugin.zsh \
 && sed -i "s/yellow/red/g" ~/.zshrc \
 && sed -i "s/blue/red/g" ~/.zshrc \
 && sed -i "s/magenta/cyan/g" ~/.zshrc \
 && sed -i "s/green/cyan/g" ~/.zshrc \
 && sed -i "s/blue/red/g" ~/.zshrc

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"