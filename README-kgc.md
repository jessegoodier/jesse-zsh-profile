# kgc: kubectl get containers

The name `kgc` is because it is like the alias `kgp` for `kubectl get pods`

`kgc` is to `k get containers` (if you don't alias k to kubectl, you should)

It also prints related errors to help fix.

![kgc-screenshot](kgc.png)

## Usage

Bash version: [.kgc.bash](.kgc.bash)
ZSH version: [.kgc.zsh](.kgc.zsh)

This is a function. Use it by sourcing it in your shell and calling one of the functions

```sh
source .kgc.zsh
```

Then run it

`kgc [namespace]`

`kgc all` will run it against all namespaces.

## Installation

>You should always read and understand a script before running it. This is a good practice to avoid running malicious code.

ZSH:

```sh
wget -O ~/.kgc.zsh https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kgc.zsh
echo "source ~/.kgc.zsh" >> ~/.zshrc
```

Bash:

```sh
wget -O ~/.kgc.bash https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kgc.bash
echo "source ~/.kgc.bash" >> ~/.bashrc
```
