# macos

Automation for getting macOS up and running.

**N.B.** that this assumes both `curl` and `git` are available (which they
appear to be on a fresh MacBook Pro).

## usage

For first time installation, open a terminal and run:

```shell
export MF_HOMEBREW_STYLE=personal; curl -Ls https://mfgo.link/macos | bash
```

For subsequent updates use the brew bundle commands directly:

```shell
brew bundle dump --file personal.brewfile
brew bundle install --file personal.brewfile
brew bundle cleanup --file personal.brewfile
```

We also have an ansible component for things that can't be managed with
homebrew. You can use normal ansible commands:

```shell
ansible-galaxy install -r requirements.yml
ansible-playbook personal.yml
```

## additional

Current shell default is still `bash` but it's changing to `zsh`.

```shell
chsh -s /bin/zsh
```
