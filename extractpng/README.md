Extract PNG
===========

As the name suggests, this tool extracts PNGs stuffed inside a file.

Why?

Because I've found firmware binary files (supposedly, updates…
haven't digged) which contain PNGs and wanted to take a look at those
images.

A PNG file can be easily spotted from a hex-ASCII dump. The [file
signature](http://www.libpng.org/pub/png/spec/1.2/PNG-Structure.html#PNG-file-signature)
can be seen easily, and then you can read the chunks, in particular
`IEND`, which marks the end of the PNG.

Samples
-------

Those PNG I've found are nothing but elements of GUIs. Things like this:

![](samples/png00011.png)

![](samples/png00015.png)

![](samples/png00064.png)

There must be Java somewhere… Not really very much exciting.


Compiling
---------

The trivial

    gcc ep.c
    
should work (on a GNU/Linux machine, at least). If not, you must find
a way by yourself.


Disclaimer
----------

Use this tool at your own risk. This has been quickly written and
mostly untested.

If there are bugs, they won't be fixed (not worth it).

