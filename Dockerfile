FROM ubuntu:latest

RUN apt-get update \
	&& apt-get install -y --no-install-recommends software-properties-common
	# && add-apt-repository -y ppa:git-core/ppa \
RUN	 apt-get update \
	&& apt-get install -y --no-install-recommends \
		apt-utils build-essential procps curl wget file git \
		apt-transport-https vim lsb-release unzip less \
		ca-certificates locales openssh-client \
		patch sudo uuid-runtime zsh
		# && rm -rf /var/lib/apt/lists/*
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.gpg \
 && apt-get update && apt-get -y install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin
ENV PATH="${PATH}:/usr/lib/google-cloud-sdk/bin/"

# RUN localedef -i en_US -f UTF-8 en_US.UTF-8 \
# 	&& useradd -m -s /bin/bash linuxbrew \
# 	&& echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
# ADD . /home/linuxbrew/.linuxbrew/Homebrew
# RUN cd /home/linuxbrew/.linuxbrew \
# 	&& mkdir -p bin etc include lib opt sbin share var/homebrew/linked Cellar \
# 	&& ln -s ../Homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/ \
# 	&& chown -R linuxbrew: /home/linuxbrew/.linuxbrew \
# 	&& cd /home/linuxbrew/.linuxbrew/Homebrew \
# 	&& git remote set-url origin https://github.com/Linuxbrew/brew

# USER linuxbrew
# WORKDIR /home/linuxbrew
# ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH \
# 	SHELL=/bin/bash \
# 	USER=linuxbrew

# # Install portable-ruby and tap homebrew/core.
# RUN HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_AUTO_UPDATE=1 brew tap homebrew/core \
# 	&& rm -rf ~/.cache

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
 && git clone https://github.com/djui/alias-tips.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/alias-tips \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
 && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
 && git clone https://github.com/superbrothers/zsh-kubectl-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt \
 && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions \
 && wget -O $HOME/.zshrc https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.zshrc \
 && wget -O $HOME/.vimrc https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.vimrc \
 && wget -O $HOME/.aliases https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.aliases

# RUN git clone https://github.com/ahmetb/kubectx /opt/kubectx \
#  && ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && ln -s /opt/kubectx/kubens /usr/local/bin/kubens \
#  && mkdir -p ~/.oh-my-zsh/completions && chmod -R 755 ~/.oh-my-zsh/completions \
#  && ln -s /opt/kubectx/completion/_kubectx.zsh ~/.oh-my-zsh/completions/_kubectx.zsh \
#  && ln -s /opt/kubectx/completion/_kubens.zsh ~/.oh-my-zsh/completions/_kubens.zsh
RUN /home/linuxbrew/.linuxbrew/bin/brew install kubectl@1.22 awscli eksctl azure-cli kubectx fzf jq yq the_silver_searcher pygments helm k9s yamllint gcc ccat

RUN (\n  set -x; cd "$(mktemp -d)" &&\n  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&\n  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&\n  KREW="krew-${OS}_${ARCH}" &&\n  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&\n  tar zxvf "${KREW}.tar.gz" &&\n  ./"${KREW}" install krew\n) \
  && kubectl krew install resource-capacity \
  && kubectl krew install cost

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
