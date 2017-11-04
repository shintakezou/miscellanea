Get HJ/HM images
================

As VW, Cy and Ca downloader, this script's aim is to download images
from a site with a specific structure, which must resemble the one of
the original site this script was written for (HJ).

Here I roughly give you a sketch of the structure

              menu.html
             /  \      \
             |   \     (etc)
             |    \
            / ../gallerie001/ABC123_N[NNN]_N[NNN].html
            |
            |
      .../gallerie001/ABC123_N[NNN]_N[NNN].html__________
             /___________ ______________________         \  next
            /            \                      \         \
       ../foto/XXX.jpg    ../foto/XXX.jpg      (etc)     next page
                                                         (recursive)


Here ABC123 denotes an alphanumeric sequence of character, N a single
number and NNN a sequence of numbers, and `[..]` an optional part
(i.e. a part that can be there or not). From each gallery (*gallerie*,
plural form in italian) it extracts links to images, their URL ending
in `/foto/SOMETHING.jpg`
(e.g. `http://www.site.net/a_dir/foto/mickymouse.jpg`)


Customizing
-----------

Of course you must customize it, and you will success if you know
regular expressions (pattern matching) language in `grep` (`egrep`),
`sed` and more...

You can customize a lot of things without changing the logic of the
script: menu.html /gallerie001/PATTERN.html (*where PATTERN stands for
a pattern you can read into the source*) /foto/EVERYTHING.jpg
(*EVERYTHING* can be everything) Avanti (*and the related pattern*)
... it's just a rough list of things you can change.

Get HM images
-------------

This is almost the same and so give you an example of customization...</p>

Here the HTML where all starts is `foto.html` (photo), each
link to a gallery is something like `A&A_N[NNN]_01.htm[l]`,
e.g. `A&A_01_01.htm`. Each gallery HTML is split into several
pages, linked by a Next link (selected by a simple pattern matching,
as before but with Next instead of Avanti); each page contains images
with src URL as `A&A_EVERYTHING.jpg`. That's all...

