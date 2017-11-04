a69 downloader
==============

This script fits the following very simple structure (customizable)


        BASEURL/palco.php?id=NUMBER&directory=annunci/TYPE/NAME&currentPic=1
            /                          /  \
           /                          /    \
      ../NAME/EVERYTHING.jpg         /     ...(etc)
                                    /
                                 (next: currentPic=2)
                                       \
                                        \
                                     (next: currentPic=3)



As you can see, it is enough to increase the *selector*
`currentPic`, but doing so we cannot know if we reached the last
one. When you ask for a picture that does not exist, maybe you get no
error, but you will get another page that can resemble to the one where
you find images you want... Even if you can identify a wrong page and so
stop increasing the counter for `currentPic`, in this way you make a
request to the site you can avoid; and since surfing the site it's
impossible to select a `currentPic` greater than the number of existing
images, you leave a clue to the webmaster saying a bot surfed in the
site. This could be a problem, especially if you want to get a lot of
these pages, resulting in a great number of wrong requests!

The NUMBER and the NAME must be given from the command line, e.g.

    $ ./a69.sh 25043 maon

You can collect NUMBER and NAME automatically of course, or just select
them by hand... As usually customization is up to you.
