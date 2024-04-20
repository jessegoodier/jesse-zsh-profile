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

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
 && apt-get update && apt-get -y install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
 && git clone https://github.com/djui/alias-tips.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/alias-tips \
 && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
 && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
 && git clone https://github.com/superbrothers/zsh-kubectl-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt \
 && git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions \
 && wget -O $HOME/.zshrc https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.zshrc \
 && wget -O $HOME/.vimrc https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.vimrc \
 && wget -O $HOME/.aliases https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.aliases \
 && sed -i "s/alias ksd/#  alias ksd/" ~/.oh-my-zsh/plugins/kubectl/kubectl.plugin.zsh \
 && wget -O /root/.kgc.sh  https://raw.githubusercontent.com/jessegoodier/kgc/main/kgc.sh \
 && sed -i "s/yellow/red/g" ~/.zshrc \
 && sed -i "s/blue/red/g" ~/.zshrc \
 && sed -i "s/magenta/cyan/g" ~/.zshrc \
 && sed -i "s/green/cyan/g" ~/.zshrc \
 && sed -i "s/blue/red/g" ~/.zshrc

RUN /home/linuxbrew/.linuxbrew/bin/brew install gcc

COPY ./.zsh_history Brewfile /root/
RUN /home/linuxbrew/.linuxbrew/bin/brew bundle --file /root/Brewfile
WORKDIR /root

CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"