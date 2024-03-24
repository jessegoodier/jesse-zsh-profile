# kgc: kubectl get containers

The name `kgc` is because it is like the alias `kgp` for `kubectl get pods`

`kgc` is to `k get containers` (if you don't alias k to kubectl, you should)

It also prints related errors to help fix.

![kgc-screenshot](kgc.png)

## TODO

1. Python pip3 installation
2. Inform user how to fix more issues
    1. PV in zone with no nodes
3. Improve performance of `kgc all`
4. Move to dedicated repo so people can follow releases
5. krew plugin

## Requirements

jq version 1.6 does not work. jq-1.7.1 does work

## Usage

This is a function. Use it by sourcing it in your shell:
```sh
source .kgc.sh
```

Then run it:

`kgc [namespace]`

`kgc all` will run it against all namespaces.

## Installation

>You should always read and understand a script before running it. This is a good practice to avoid running malicious code.

```sh
wget -O ~/.kgc.sh https://raw.githubusercontent.com/jessegoodier/jesse-zsh-profile/main/.kgc.sh
echo "source ~/.kgc.sh" >> ~/.zshrc
echo "source ~/.kgc.sh" >> ~/.bashrc
```
