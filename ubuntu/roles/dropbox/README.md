# dropbox

Installs the dropbox client for linux. We don't use the provided `.deb`
package from upstream because part of the post install steps attempt to add
the upstream repository, but they haven't provided a distribution since before
at least `focal`.

Instead we follow the same pattern as the dropbox package on the
[AUR](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=dropbox) and
extract the "offline" installer into `/opt`. Unfortunately, this requires
keeping up-to-date manually with the upstream release version numbers which
can be found
[here](https://www.dropboxforum.com/t5/Desktop-client-builds/ct-p/101003000).
