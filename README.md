```
             ,-. 
    ,     ,-.   ,-. 
   / \   (   )-(   ) 
   \ |  ,.&gt;-(   )-&lt; 
    \|,' (   )-(   ) 
     Y ___`-'   `-' 
     |/__/   `-' 
     | 
     | 
     |    -ami- 
  ___|_____________ 
```
dotfiles and ~/bin
---

A collection point for my various dotfiles, binaries, and what ever I find on old harddrives and usb keys that I want to keep.
Dust bunnies and all.

:: Please refer to the [Keeping your home in Git, the right way](./HOWTO.md) for instructions for setting up the repo locally.<br/>
:: [Hide tab bar when using TreeStyle Tabs in Firefox](./hide-tabs-in-firefox-treestyle.md)<br/>
:: [Local Git Repo Setup](./git-setup.md)<br>

Things to do after a clean Linux Install.
---

* Ask: Has this already been automated? Can this be automated now?
* [Update and install the usual packages](./install-packages.md)
* [https://github.com/magicmonty/bash-git-prompt](https://github.com/magicmonty/bash-git-prompt)

Force local sync against remote
---

If you are taking a home directory and bringing it into alignment with the remote the following code will do that. The last step will delete all local data that doesn't match what's on the remote.

Remember to replace origin and master with the remote and branch that you want to synchronize with.

```
git init --bare $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no
config remote add origin git@github.com:aaron-imbrock/dotfiles.git
config fetch origin
config reset --hard origin/main
config clean -f -d
```
