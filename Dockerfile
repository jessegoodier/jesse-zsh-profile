FROM ubuntu:latest

RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  apt-utils build-essential procps curl wget file git \
  apt-transport-https vim lsb-release unzip less \
  ca-certificates locales openssh-client \
  patch sudo uuid-runtime zsh

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.gpg \
 && apt-get update && apt-get -y install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
 && git clone https://github.com/djui/alias-tips.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/alias-tips \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
 && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
 && git clone https://github.com/superbrothers/zsh-kubectl-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt \
 && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions \
 && wget -O $HOME/.zshrc https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.zshrc \
 && wget -O $HOME/.vimrc https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.vimrc \
 && wget -O $HOME/.aliases https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.aliases

RUN /home/linuxbrew/.linuxbrew/bin/brew install awscli eksctl azure-cli kubectl kubectx fzf jq yq the_silver_searcher pygments helm k9s yamllint gcc ccat

RUN ( set -x; cd "$(mktemp -d)" &&  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&  KREW="krew-${OS}_${ARCH}" &&  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&  tar zxvf "${KREW}.tar.gz" &&  ./"${KREW}" install krew)

COPY ./.zsh_history /root
WORKDIR /root

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
