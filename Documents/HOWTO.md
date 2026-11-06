<header>

</header>

<article>

# Keeping your home in Git, the right way

Published on <span id="pubdate">2014-12-17</span>. Modified on <span id="moddate">2021-04-08</span>.
Article copied from https://www.unixsheikh.com/tutorials/keeping-your-home-in-git.html and updated by Aaron Imbrock for personal use.

This tutorial describes how you can keep your home directory in a Git repository.

So a lot of interesting websites on the Internet are talking about the benefits and pitfalls of keeping your entire $HOME directory in Git. As with most technology there are many ways to accomplish the same goal, but some are better than others.

Some are using makefiles with a lot of symbolic links, others are using a huge `.gitignore` which results in an unmaintainable nightmare, others are trying to script themselves out of the problems. But there actually exists a really easy and simple way to accomplish this.

First of all, it makes no sense at all to keep your entire $HOME in a Git repository. Only the relevant files in your $HOME should be put in Git. But how do we accomplish that while at the same time not having to maintain a huge `.gitignore` with a bunch of files to ignore (that we have to remember to update each time an unimportant file gets added to our $HOME)? And what about other Git repositories that resides in our $HOME directory as well?

Here's how you can accomplish your goal. Create a `.gitignore` in your $HOME directory and let it only contain a single asterisk sign `*`.

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

This is a really simply, yet powerful way to keep your $HOME directory in Git.

So, how do you clone your $HOME directory from your bare repository server to a new box?

Let's say you're using some remote SSH server as your bare git repository (called home.git)

<pre>$ git clone --bare . home.git</pre>

You then need to upload that to your SSH server and turn it into your origin:

<pre>$ git remote add origin ssh://foo@bar.com/home/foo/repo/home.git</pre>

You can also just log into the server and create the remote repository there:

<pre>$ mkdir -p foo/repo/home.git
$ cd foo/repo/home.git
$ git init --bare</pre>

The first time you need to push something you need to set it upstream:

<pre>$ git push --set-upstream origin main</pre>

Now you can push and pull to the remote repository from your $HOME directory.

But what if you have just finished installing your favorite Linux or BSD on a new box and of want a copy of your $HOME on this new machine. You cannot simply start cloning.

This will **NOT** work:

<pre>$ git clone ssh://foo@bar.com/home/foo/repo/home.git</pre>

Git will complain with:

<pre>fatal: destination path '.' already exists and is not an empty directory.</pre>

This makes sense.

And you cannot do a "pull" either as Git will complain about overwriting files - if similar files already exists.

What you need to do on the new box is this:

<pre>$ git init
$ git remote add origin ssh://foo@bar.com/home/foo/repo/home.git
$ git fetch
$ git reset --hard origin/main</pre>

Again, the first time you need to push something you need to set it upstream:

<pre>$ git branch --set-upstream-to origin/main</pre>

The same goes if you begin by a pull.

Now you can push and pull on that box too.

That's it!

</article>
