# Set Git Global Defaults
```git
git config --global user.name 'Aaron Imbrock'
git config --global user.email 'aimbrock@gmail.com'
git config --global core.editor "code --wait"
git config --global init.defaultbranch main
git config --global pull.rebase false
git config --global core.pager "cat"
git config --global core.sshCommand "ssh -o IdentitiesOnly=yes -i ~/.ssh/stilnox_git"
```

# Create a new repository on the command line

```git
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin git@github.com:aaron-imbrock/test.git
git push -u origin main
```

# Push an existing repository from the command line

```git
git remote add origin git@github.com:aaron-imbrock/test.git
git branch -M main
git push -u origin main
```
