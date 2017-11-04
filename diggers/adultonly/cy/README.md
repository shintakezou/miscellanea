Cy downloader
=============

This script can be useful for downloading all kind of things if the
structure of the “site” we are going to meet matchs that of a hot
site I won't mention.

In order to use this script I am going to explain you the features
the target site should have. Of course you can change details so that
you reach your purpose.

When you have chosen the right site, you can edit the script and put
its address inside, and the run it... (See log if something goes wrong)

**REQUIREMENTS**: you need my own `getaddrs` and
`ginlineimg`. Maybe you can find them (the source code, of course)
somewhere in my site. Otherwise, just argue what they do and code something
by yourself! Note: these are old tools of mine, now I am using Perl scripts
for the same purpose.

**Details** are not explored, but I give you old scripts for the
same purpose — I did not get it in one shot!



What Cy does
------------

First, suppose your site is SITE (e.g. `http://www.site.org/dir/main`).
The script tries to download `index1.html` (you can change this!). Then,
it searchs for URL of the form `index200N.htm[l]` where
N is a number and `[l]` is an optional “`l`”. E.g.
it downloads index2000.htm, index2001.html, index2002.html and so on. Of
course, you can change the criteria Cy chooses the *indexes* to be
donwloaded.

Now, for every downloaded index, it extracts links that looks like
`pAAA/00N.htm[l]`, where AAA is a sequence of lowercase letters, N a
number and `[l]` is an optional `l`. For each of these links, it gets
the *dirname* and create a dir with that name (if it does not exist),
and downloads that link (we are dealing with a lot of HTML files
here), if it is not already downloaded.

Now we have reached the final level: inside the HTML files that match
the name `00N.htm[l]` (which is not a regular expression or matching
pattern for computers!) there are links to resources, and these are
linked through a “*next* chain”.

So the **recursive** function `browse` explores the rest of the
structure... How?

Each “browsed” HTML contains links in the form of `NNN.htm[l]` where
NNN is a sequence of numbers. These new HTML file are downloaded. At
last, these files contain other links of the same form (NNN.htm);
these, at the end of the game, contain the link we are interested in.

So, this last downloaded treasure is scanned for image-links, just
using a program that gets the links in the `src` attribute of the
`img` HTML tag, and selecting those links ending in `.jpg` (easy!)

When all downloads from the “main” page containing link to other pages
containing links to the resources are finished, the (almost) top-level
index is checked for next, i.e. links as `NNNAAAA.htm`. Then this
*next* feeds `browse` function again, and here the recursion starts.

A sketch of the structure follows

           **index1.html____
             /         \    \
            /           \    (etc)
           /           index2001.htm
      **index2000.htm___
        /       \   \   \
       /         \   \  pAAA/(etc)
      /           \  pAAA/001.htm
     pAAA/000.htm  \______ _______________
                    \     \               \
                     \    pBBB/001.htm    p(etc)/(etc)
                  **pBBB/000.htm
         ________/_____ ________
        /     \        \        \
    *1.htm  *2.htm   ***20.htm   (etc)
                        /  \_____________ next _________
                       /                                \
                ______/__________________________      *20aba.htm
               /     \        \         \        \         \
            §00.htm §01.htm  §02.htm  §03.htm    (etc)      \ next
             /        \         \        \                   \
           XX.jpg    XX.jpg     XX.jpg   XX.jpg            *20abb.htm
           YY.jpg    YY.jpg     ...      ...                  \
           ZZ.jpg                                           *20abc.htm
           .                                                   \
           .                                                  (etc)
           .
          (etc)

    *Italics is the thumbnails level
    § is the large picture level
    **Bold are the links we follow as example
	***Italics+Bold = thumbnails level and a link we follow

The whole idea is that they have different indexes, one per year. Each
of these year-index points to several numbered indexes located into
directories (think as they were cities: Rome, Venice, London and so on,
and for every city we have several locations, referred by number). Each
“location” has points to themes (e.g. monuments in that place,
details of the roads around and so on). Each theme page shows thumbnail
pictures of the theme (in that location of that city), and when
the thumbnails are too much, there's a link to the next page of the
same theme. Each thumbnails do not link to the big picture, rather
it links another HTML file that contains the large picture, and this
is what we shall download (for several reasons, the same HTML containing
the large version of the thumbnail image can contain other images, so
we *loop* to download them all).

Last resort to make it clear: index1.html points to index2000.html that
points to London/TrafalguarSquare.html that points to Banks.html,
Jewels.html, Playgrounds.html, Houses.html and so on; Houses.html has
thumbnails of all the houses around the square, clicking on each
small picture you get a new page that *contains* the big picture
(you are interested in); since there are so many houses, Houses.html
points to HousesB.html, that points to HousesC.html and so on...

Dealing with recursion
----------------------

What if there's not only a next but a previous too? And what happens
if the last “next” indeed points to the first?! Here it seems we
do not take these into account, and in fact so it was. Anyway I give
you better scripts too, that deal with several problems. And more
scripts for other purposes:

- `sfoltisci.sh` tries to delete the thumbnails downloaded by mistake.
- ...other scripts that you can study rather than use...

