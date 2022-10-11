# jesse-zsh-profile

This repo contains my favorite zsh profile settings. It is always a WIP. Use at your own risk.

My goal with sharing it is to help those that want and easy to test zsh shell with auto completion, useful prompt and colorful output with most tasks.

I work at Kubecost and we use AWS/Azure/GCP every day. They each have thier own quirks with installation and completion as you can see in the Dockerfile.

The docker image contains a .zsh_history file pre-loaded with common commands to login and list clusters. Easily removed if it is distracting.

The .zshrc needs a little clean up, but it works for now.

## usage

Build your own:
```
git clone git@github.com:jessegoodier/jesse-zsh-profile.git
cd jesse-zsh-profile
docker build --tag zsh-admin-tools .
docker run -i -t --rm zsh-admin-tools:latest zsh
```

Or use prebuilt image:

```
docker run -i -t --rm jgoodier/zsh-admin-tools:latest zsh
```