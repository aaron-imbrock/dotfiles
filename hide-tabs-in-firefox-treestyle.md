# Hide tab bar when using TreeStyle Tabs in Firefox

Taken partially from https://www.userchrome.org/how-create-userchrome-css.html

## In Firefox:

Install [TreeStyle Tabs](https://addons.mozilla.org/en-US/firefox/addon/tree-style-tab/)

Type or paste `about:config` in the address bar and press Enter/Return to load it.

In the search box above the list, type or paste `userprof` and pause while the list is filtered. If you do not see anything on the list, ignore this step.

Switch `toolkit.legacyUserProfileCustomizations.stylesheets` preference from false to true.

Type or paste `about:support` in the address bar and press Enter/Return to load it.

Note the `Profile Directory`.

## In Terminal:

cd to `Profile Directory` and create a folder called `chrome`.

Note, that on newer versions of Firefox `Update Folder` is in the field where you previously expected to see `Profile Folder`. `Profile Folder` is now farther down.

```bash
mkdir chrome;

cat << EOF > ./chrome/userChrome.css

/* #main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar > .toolbar-items {
  opacity: 0;
  pointer-events: none;
}
#main-window:not([tabsintitlebar="true"]) #TabsToolbar {
    visibility: collapse !important;
} */

#titlebar { visibility: collapse !important; }

EOF
```

In Firefox again:



Restart all Firefox sessions.

