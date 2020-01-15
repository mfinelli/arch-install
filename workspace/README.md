# workspace

Configuration for setting up and AWS workspace.

## manual steps:

1. Copy ssh key from host and set permissions (600)

```shell
mkdir -p ~/.ssh
vi ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
```

2. Run the script: `./bootstrap.bash`

```shell
mkdir -p ~/src/mfinelli
cd ~/src/mfinelli
git clone git@github.com:mfinelli/arch-install.git
cd arch-install/workspace
./bootstrap.bash
```

3. Configure cloud utilities

```shell
gcloud init
aws configure
```
