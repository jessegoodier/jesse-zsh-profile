#!/bin/bash
set -xe



[ -d $HOME/profile-backup ] && echo "Please move the $HOME/profile-backup dir before proceeding." && exit

if [ "$EUID" != "0" ]; then
  dosudo="sudo"
fi

# todo: brew for all installs?
# which package manager is installed?
pacman="none"
[ -x "$(command -v yum)" ] && pacman="yum" && $dosudo $pacman install yum-utils util-linux-user epel-release -y && $dosudo $pacman update -y
[ -x "$(command -v zypper)" ] && pacman="zypper"
[ -x "$(command -v apt-get)" ] && pacman="apt-get" && $dosudo $pacman update -y
[ -x "$(command -v brew)" ] && pacman="brew"

[ "$pacman" = "none" ] && echo "no pacman!" && exit

yy="-y"
# [ $(uname | tr '[:upper:]' '[:lower:]')="darwin" ] && dosudo="" && yy=""

echo 'Updating/Installing zsh.' >&2
$dosudo $pacman install $yy zsh

if ! [ -x "$(command -v wget)" ]; then
  echo 'Installing wget.' >&2
  $dosudo $pacman install $yy wget
fi

if ! [ -x "$(command -v git)" ]; then
  echo 'Installing git.' >&2
  $dosudo $pacman install $yy git
fi

# get most recent vim 
$dosudo $pacman install $yy vim 

# make backups
mkdir -p $HOME/profile-backup
[ -d "$HOME/.oh-my-zsh" ] && mv "$HOME/.oh-my-zsh/" "$HOME/profile-backup"
[ -f "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/profile-backup"
[ -f "$HOME/.aliases" ] && mv "$HOME/.aliases" "$HOME/profile-backup"
[ -f "$HOME/.vimrc" ] && mv "$HOME/.vimrc" "$HOME/profile-backup"
[ -f "$HOME/.config/yamllint/config" ] && mv "$HOME/.config/yamllint/config" "$HOME/profile-backup"
[ -f "$HOME/.vim/syntax/nginx.vim" ] && mv "$HOME/.vim/syntax/nginx.vim" "$HOME/profile-backup"

# install zsh and plugins
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/djui/alias-tips.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/alias-tips
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/superbrothers/zsh-kubectl-prompt.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-kubectl-prompt
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)

    # set default shell to zsh for this user
    $dosudo chsh $USER -s /usr/bin/zsh
    wget -O $HOME/.zshrc https://gist.githubusercontent.com/jessegoodier/5cadc498d2141594107279c16803355a/raw/.zshrc

    if [ -x "$(command -v apt-get)" ]; then
        echo 'tzdata tzdata/Areas select US' | $dosudo tee debconf-set-selections
        echo 'tzdata tzdata/Zones/US select Eastern' | $dosudo tee debconf-set-selections
        DEBIAN_FRONTEND="noninteractive" $dosudo apt install -y software-properties-common apt-transport-https lsb-release ca-certificates tzdata python3-pip
    fi

    if [ -x "$(command -v yum)" ]; then
        $dosudo yum install -y python39 ca-certificates
        if [ -x "$(command -v setenforce)" ]; then 
          $dosudo setenforce 0
          $dosudo sed -i 's/enforcing/disabled/' /etc/selinux/config
        fi
        pidof /sbin/init && echo "sysvinit" |$dosudo systemctl disable --now firewalld.service
        $dosudo update-alternatives --set python /usr/bin/python3.9
    fi
    
    
    # if ! [ -x "$(command -v bat)" ] && [ -x "$(command -v apt-get)" ]; then
    #     wget https://github.com/sharkdp/bat/releases/download/v0.18.3/bat_0.18.3_amd64.deb
    #     $dosudo $pacman install $yy ./bat_0.18.3_amd64.deb
    #     rm bat_0.18.3_amd64.deb
    # fi

    if ! [ -x "$(command -v exa)" ] && [ -x "$(command -v apt-get)" ]; then
        wget https://nginx-presales.s3.us-west-1.amazonaws.com/exa
        $dosudo mv exa /usr/local/bin
        $dosudo chmod +x /usr/local/bin/exa
    fi

    if [ "$(ack --version|awk '{print $2}'|head -n1)" = "v3.5.0" ] || ! [ -x "$(command -v ack)" ]; 
        then wget https://beyondgrep.com/ack-v3.5.0 -q && $dosudo chmod +x ack-v3.5.0 && $dosudo mv ack-v3.5.0 /usr/bin/ack 
    fi

    ;;
  darwin*)
    wget -O $HOME/.zshrc https://gist.githubusercontent.com/jessegoodier/5cadc498d2141594107279c16803cd355a/raw/.zshrc-macos
    [ -x "$(command -v brew)" ] && brew install exa
    # [ -x "$(command -v brew)" ] && brew install bat
    ;;
esac

[ -x "$(command -v zypper)" ] && ! [ -x "$(command -v bat)" ] && $dosudo zypper install $yy bat

wget -O $HOME/.vimrc https://gist.githubusercontent.com/jessegoodier/5cadc498d2141594107279c16803355a/raw/.vimrc
wget -O $HOME/.aliases https://gist.githubusercontent.com/jessegoodier/5cadc498d2141594107279c16803355a/raw/.aliases
wget -O $HOME/zsh-updater.sh https://gist.githubusercontent.com/jessegoodier/5cadc498d2141594107279c16803355a/raw/oh-my-zsh-vim-settings-installer.sh
# vim syntax highlighting for nginx conf files
mkdir -p $HOME/.vim/syntax/
wget http://www.vim.org/scripts/download_script.php?src_id=19394 -O $HOME/.vim/syntax/nginx.vim

touch $HOME/.vim/filetype.vim
# Set locations of NGINX config files for vim
if [[ $(grep -L nginx ~/.vim/filetype.vim)  ]];
then echo "au BufRead,BufNewFile nginx.conf,/etc/nginx/*,/etc/nginx/conf.d/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif">>$HOME/.vim/filetype.vim
fi

mkdir -p $HOME/.vim/pack/git-plugins/start
[ ! -d "$HOME/.vim/pack/git-plugins/start/ale" ] && git clone --depth 1 https://github.com/dense-analysis/ale.git $HOME/.vim/pack/git-plugins/start/ale


pip3 install --upgrade pip
if ! [ -x "$(command -v yamllint)" ]; then
  echo 'Installing yamllint.' >&2
  pip3 install --user yamllint
fi

if ! [ -x "$(command -v crossplane)" ]; then
  echo 'Installing crossplane.' >&2
  pip3 install --user crossplane
fi
if ! [ -x "$(command -v fuck)" ]; then pip3 install --user thefuck; fi
if ! [ -x "$(command -v pygmentize)" ]; then pip3 install --user pygments; fi

if ! [ -f "$HOME/.config/yamllint/config" ]; then
mkdir -p $HOME/.config/yamllint
cat > $HOME/.config/yamllint/config <<EOF
extends: relaxed
rules:
  line-length: disable
EOF
fi