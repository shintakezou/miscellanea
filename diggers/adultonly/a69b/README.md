a69 downloader
==============

Recently I've visited again the site for which
[a69.tar.gz](http://www.capo-nord.org/soci/xmav/scripts/net/a69.tar.gz)
was made. It is changed; you can still access it with my former
script, anyway this new perl script does the work once you download
the needed *autoplay* gallery. The method can work with other sites.

Usage:

    $ ./download.pl <"Dwk5k1kl6kxgd_-_Xj9_0z93l:_?.html"

The `?` directory is created and the downloaded targets are
stored inside it. You can pipe the files since `download.pl`
is aware of the change of `?`.

    cat collected/*.html | ./download.pl

Don't ask which site, nor how to let it work on MS Windows, or such
questions. Study the code and be happy with it.
