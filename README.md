# jesse-zsh-profile

> kgc `kubectl get containers` has its moved to its own [repo](https://github.com/jessegoodier/kgc)
> This repo contains my favorite zsh profile settings. It is always a WIP. Use at your own risk.

My goal with sharing it is to help those that want an easy to use zsh shell with auto completion, useful prompt and colorful output for most tasks.

I work at Kubecost and we use AWS/Azure/GCP every day. `google-cloud-sdk` install is broken, consider the much smaller <https://hub.docker.com/r/alpine/k8s/tags>.

It has the GCP/AWS/Azure CLIs, kubectl (k), kubectx (kx/kn) preloaded.

The docker image contains a .zsh_history file so you can see history recommendations with common commands to login and list clusters. This is easily removed if it is distracting.

The .zshrc needs a little clean up, but it works for now.

## Usage

> This Docker image is huge! It is only for testing purposes, though it is useful for experimenting with profile changes without risk.

You can copy the commands out of the [Dockerfile](Dockerfile) for the items you want to install in your shell.

Or use a the [prebuilt image](https://hub.docker.com/r/jgoodier/zsh-admin-tools)

### Dockerfile

You can safely test these settings in a Docker container without impact to your current terminal.

You can build your own image (this will take a long time to build):

```sh
git clone git@github.com:jessegoodier/jesse-zsh-profile.git
cd jesse-zsh-profile
docker build --tag zsh-admin-tools .
docker run -i -t --rm zsh-admin-tools:latest zsh
```

Or use a prebuilt image:

```sh
docker run -i -t --rm jgoodier/zsh-admin-tools:latest zsh
```

Profile credentials to your AWS/Azure/GCP accounts:

```sh
az login
```

```sh
aws configure
```

```sh
gcloud auth login
```

Get the cluster contexts:

```sh
cloud-get-all-eks-clusters
```

```sh
cloud-get-all-aks-clusters
```

```sh
cloud-get-all-gcp-clusters
```

Use tab completion with kubectl:

```sh
kubectl get pods <tab>
```

Or set the context to your namespace:

```sh
kn <tab>
```

then
```sh
kgp <tab> -oyaml
```

use kgc (kubectl get containers)!

```sh
kgc -A
```

### Install krew

install krew:
<https://krew.sigs.k8s.io/docs/user-guide/setup/install/>

Install the best krew tools once in the shell:

```sh

k krew install resource-capacity
k krew install cost
```
