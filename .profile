# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ] ; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# uv, pipx, pip, and vendor installs expect this. 
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# set GOPATH so it includes user's GO bin if it exists
if [ -d "$HOME/go/bin" ] ; then
    PATH="$HOME/go/bin":$PATH"
fi

#alias cat="batcat"
# PATH=$PATH:/usr/local/go/bin
# export PATH=/home/aimbrock/x-tools/arm-kindlehf-linux-gnueabihf/bin:$PATH
# export PATH="$HOME/go/bin:$PATH"