# jesse-zsh-profile

> kgc `kubectl get containers` has its moved to its own [repo](https://github.com/jessegoodier/kgc)

> This repo contains my favorite zsh profile settings. It is always a WIP. Use at your own risk.

My goal with sharing it is to help those that want an easy to use zsh shell with auto completion, useful prompt and colorful output for most tasks.

I work at Kubecost and we use AWS/Azure/GCP every day. They each have thier own quirks with installation and completion as you can see in the Dockerfile.

It has the GCP/AWS/Azure CLIs, kubectl (k), kubectx (kx/kn) preloaded.

The docker image contains a .zsh_history file so you can see history recommendations with common commands to login and list clusters. This is easily removed if it is distracting.

The .zshrc needs a little clean up, but it works for now.

## Usage

You can copy the commands out of the [Dockerfile](Dockerfile) for the items you want to install in your shell.

Or use a the [prebuilt image](https://hub.docker.com/r/jgoodier/zsh-admin-tools)

### Dockerfile

Build your own (this will take a long time to build):

```sh
git clone git@github.com:jessegoodier/jesse-zsh-profile.git
cd jesse-zsh-profile
docker build --tag zsh-admin-tools .
docker run -i -t --rm zsh-admin-tools:latest zsh
```

Or use prebuilt image:

```sh
docker run -i -t --rm jgoodier/zsh-admin-tools:latest zsh
```

install krew:
<https://krew.sigs.k8s.io/docs/user-guide/setup/install/>

Install the best krew tools once in the shell:

```sh

k krew install resource-capacity
k krew install cost
```
