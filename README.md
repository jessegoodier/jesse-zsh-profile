# jesse-zsh-profile

> kgc `kubectl get containers` has its moved to its own [repo](https://github.com/jessegoodier/kgc)
> This repo contains my favorite zsh profile settings. It is always a WIP. Use at your own risk.

My goal with sharing it is to help those that want an easy to use zsh shell with auto completion, useful prompt and colorful output for most tasks.

I work at Kubecost and we use AWS/Azure/GCP every day. `google-cloud-sdk` install is broken, consider the much smaller <https://hub.docker.com/r/alpine/k8s/tags>.

It has the GCP/AWS/Azure CLIs, kubectl (k), kubectx (kx/kn) preloaded.

The docker image contains a .zsh_history file so you can see history recommendations with common commands to login and list clusters. This is easily removed if it is distracting.

The .zshrc needs a little clean up, but it works for now.

## Usage

create a container:
```sh
docker run -i -t --name jesse-zsh-profile \
 -v $PWD:/root ubuntu:latest
```

run setup:

```sh
bash /root/ubuntu-setup.sh
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
kgp <tab>
```


### Install krew

install krew:
<https://krew.sigs.k8s.io/docs/user-guide/setup/install/>

Install the best krew tools once in the shell:

```sh
k krew install resource-capacity
k krew install cost
k krew install images
k krew install ktop
k krew install browse-pvc
k krew install config-cleanup
```
