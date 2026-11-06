# Install necessary packages
### TODO
```
* Base /etc/apt/source.list requires addition of at least 'contrib'
```
### Initial
```bash
sudo apt update
sudo apt install -y curl vim software-properties-common python3-launchpadlib
```
### Install s3 mountpoint
Official Doc: https://docs.aws.amazon.com/AmazonS3/latest/userguide/mountpoint-installation.html

```bash
cd /tmp/
wget https://s3.amazonaws.com/mountpoint-s3-release/latest/x86_64/mount-s3.deb
sudo apt-get -y install ./mount-s3.deb
```

### VSCODE and Sublime APT REPOS
```bash
# VSCODE
sudo apt-get install wget gpg &&
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg &&
sudo install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg &&
rm -f microsoft.gpg
```
Create a `/etc/apt/sources.list.d/vscode.sources` file with the following contents to add a reference to the upstream package repository:
```bash
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: amd64,arm64,armhf
Signed-By: /usr/share/keyrings/microsoft.gpg
```
```bash
# Sublime
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
```

### Install packages
```bash
sudo apt update
sudo apt-get install -y apt-transport-https curl \
  git vim build-essential fonts-inconsolata code sublime-text \
  keepass2 ca-certificates debsig-verify ttf-mscorefonts-installer \
  tree rsync neovim alacritty
```

### Update fonts cache
```bash
# Clear and regenerate your font cache
sudo fc-cache -fv
fc-list | grep -i consolata
```
### Set Sublime as default editor
```bash
sudo update-alternatives --install /usr/bin/editor editor $(which subl) 10
sudo update-alternatives --set editor $(which subl)
```

### Install Kee plugin

Docs: [https://github.com/kee-org/browser-addon](https://forum.kee.pm/t/upgrading-keepassrpc/22)

KeePassRPC.plgx file from https://github.com/kee-org/keepassrpc/releases/latest => “sudo cp ~/KeePassRPC.plgx /usr/lib/keepass2/Plugins/KeePassRPC.plgx”
Quick instructions

    Download the latest KeePassRPC.plgx file from https://github.com/kee-org/keepassrpc/releases/latest and move it to your KeePass plugins folder, usually “C:\Program Files (x86)\KeePass Password Safe 2\Plugins” - just overwrite the older file that’s already in that folder.
    Restart KeePass to enable the new plugin.

Set Permissions (Recommended): Set the owner to root to avoid setup messages, as suggested by a user on Reddit.

    Command: `sudo chown root:root /usr/lib/keepass2/Plugins/KeePassRPC.plgx `

Restart KeePass: Restart KeePass to load the new plugin. 
Setup Browser Extension: Install the Kee browser extension to connect to the RPC service. 
