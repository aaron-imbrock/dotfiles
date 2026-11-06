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

Baseline of my home folder.

Theory
---

Create a `.gitignore` in your $HOME directory and let it only contain a single asterisk sign `*`.

<pre>$ echo "*" > .gitignore</pre>

The asterisk sign in `.gitignore` makes Git ignore everything by default, which is exactly what we want. Then we just add stuff manually from $HOME into Git with the `-f` (force) option:

<pre>$ git init
$ git add -f foo.txt
$ git add -f bar.txt
$ git commit -a -m "Add two new files"
$ git remote add origin git@github.com:aaron-imbrock/dotfiles.git
$ git push -u origin main</pre>

Now the files `foo.txt` and `bar.txt` has been added to our $HOME Git repository and everything else has been ignored.

The benefit of this approach is:

*   You're using a white list and only adding stuff you really need Git to follow.
*   All other repositories in $HOME automatically gets ignored and they are not effected by your main .gitignore in your $HOME.
*   Your $HOME Git repository is not affected by any other .gitignore in another ignored repository.
*   You don't have to update .gitignore.
*   If you're using a remote bare repository you can then easily push and pull to and from that repository without affecting any other files in your $HOME.

You just have to remember to add files manually using the `-f` options and then commit changes when needed and it's easy to turn that into an alias.