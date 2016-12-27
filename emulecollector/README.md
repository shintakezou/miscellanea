# List and select links from eMule collection

It's [emulecollector.py](emulecollector.py).

The tool `ed2k` can do what you need, but many users need GUIs. Here
comes this Python script: it uses Gtk to **list** the collection's
content and makes it possible to **select** links you want to
“send” to *aMule*.

Hopefully your modern desktop environment allows you to associate
`.emulecollection` extension to the script.

It basically uses `ed2k -l` to obtain a list of the links in the
collection, then uses `ed2k` to “send” each selected links to
*aMule*. Actually it means that those links are written into a file,
so you don't need to have *aMule* running.

I wrote this for a sister who told me she remembers she had such a
tool on her previous distro. Since I am her system administrator,
I am guilty of having left Ubuntu for Debian and it seems other
found solutions didn't work as expected…

Requirements as *apt-get install* suggestions (plus all their implied
requirements, here unlisted):

- amule-utils (tested with 2.3.1)
- python-gtk2 (tested with 2.24.0)

