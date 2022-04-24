# ubuntu

Automation for ubuntu gaming and/or media installation based on a "minimal"
ubuntu desktop installation (without enabling third party software during
install).

```shell
sudo apt update && sudo apt upgrade
```

```shell
sudo apt install curl
```

```shell
bash -c "$(curl -fsSL https://mfgo.link/ubuntu)"
```

**N.B.** there is not a dedicated role for [Mullvad](https://mullvad.net) at
this time because they do not provide an apt repository, just single `.deb`
packages, so updates need to be performed manually in `ubuntu.yml` directly.
