Ca downloader
=============

As *Cy downloader*, this one was thought to work with a specific
italian site. The site is divided by regions, each “region HTML”
contains *information* (images) we want.

The regions are downloaded into the `store` dir (names can be
changed), passing `regione=REGIONE` to a specific ASP page, you can
change according to your need of course.  Each region HTML contains
advertisements (italian *annuncio*, plural *annunci*), identified by
an ID number which is extracted just to provide a name for the text of
the advertisement. Each advertisement page (downloaded with the url
containing `show_annuncio.asp` followed by its ID) can contain images,
that are downloaded, and that's all.

In order to proper use this script, you have to pass a list of regions
on the command line. For example:

    $ ./getcaall.sh Abruzzo Molise Marche

Where Abruzzo, Molise, Marche are italian regions. Names must match
the name in the site of course, but this details is up to you.

Since the list of regions is in another HTML file, if you have this
you can call the Ca downloader with `-l` as first argument, and as
second argument the file where you know there are the links to regions
(`fa_menu.asp?regione=` is the “template” to recognize the region URL)

Of course, you need to customize this script in order to use with a
site that fits this structure!

