# macos

Automation for getting macOS up and running.

**N.B.** that this assumes that both `curl` and `git` are available (the
former appears to be on both a fresh MacBook Pro and MacBook Air, the latter
needs to be installed manually first either by installing Xcode from the App
Store or by running `xcode-select --install`, then you must accept the
license by running `sudo xcodebuild -license`)

If you have `mas` entries in the brewfile that you intend to use be sure to
login to the App Store first!

## usage

For first time installation, open a terminal and run:

```shell
export MF_HOMEBREW_STYLE=personal
bash -c "$(curl -fsSL https://mfgo.link/macos)"
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

You may want to change your shell to `zsh` provided by homebrew because it
will be newer and more up-to-date than what is provided by macOS.

```shell
chsh -s "$(brew --prefix)/bin/zsh"
```

## manual installs

Because homebrew cask does a full uninstall and reinstall during upgrades it's
inconvenient to install steam or creative cloud using brew and so those need
to be installed and updated manually.
