Voyeurweb Download Scripts
==========================

<div class="alert">
These scripts/tools are meant to download adult-only images. If you don't
like it, just stop reading and go back playing in the garden.
</div>

These tools were created in order to mass-download pictures on the Voyeurweb
site, which ~~offers~~ offered tons of pictures (most of them amatorial). These are not
**hard** pictures, because when the things get hot, they are moved to
the *explicit*section, called Redclouds (you have to pay for it if
you want to get in—or find a password!)

Anyway, these scripts/tools give several ideas that can be used for more
educative purposes. At last I've decided not to convert them to generic
tool (it would have been boring and I am lazy), but **keep in mind**:
you can use the ideas in these scripts to download more interesting
things!

Here I will document very briefly these tools. **Notice** that the
only scripts really dealing with VW are choose.sh and vwdigger.sh! And
these can be used for other purposes just changing some details (e.g.,
the address of the site)! And here it comes the educational part of
these scripts...


choose.sh
---------

It chooses from the global list a number of one kind of links (voy,
vw, ps) and enqueues these links to the download list; or it selects
one kind of link in the download list (stufflist), the unselected
links go back to the global list.


purgelist.sh
------------

It deletes from the global list the already downloaded links, or those
that are in the tabu list.

getaddrs.pl
-----------

It extracts links from a HTML file (using pattern matching, so it is not
so smart).


getstuff.sh
-----------

It starts the download of the stufflist (download list), checking for
unique links and so on; at the end, the links are put into the
downloaded list, and stufflist is deleted.


nocr.pl
-------

It replaces CR with LF; it seems they use Mac at Voyeurweb!


purgelist.sh
------------

It synchronises the global list with the downloaded and the taboo
list.


select.sh
---------

It selects a given number of links from the head of stufflist, and the
remaining links are sent back to the global list. It resembles
choose.sh, but this tool is used just to limit the number of download,
if you have no time.


uniquecheck.sh
--------------

It checks the stufflist (download list) for already downloaded links
or links into the taboo list; it can be useful if you add links by
hand to the stufflist.


vwdigger.sh
-----------

It contacts the VW site and updates the global list, or adds links from
a local file (offline). Then it checks the global list for downloaded
or taboo links, and then adds a number (by default 10) of these new links to
the end of the stufflist (download list). If you do not specify the
`nodownload` option, it starts downloading the links in stufflist,
and updates the global list as getstuff.sh does.

