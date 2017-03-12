Read and create Microsoft Windows Shortcut files
================================================

These are stuffs found digging into an archeological storage. First
date in the original `README` is 2007-06-15. There's an update with
date 2008-04-13.

I was suggesting to use `winedump` to check the generated `.lnk`.

Currently you can try
[lnk-parse](https://github.com/lcorbasson/lnk-parse) instead, and also
`exiftool` could work. The output of these programs on the LNK file
given as example suggests you can't trust `wlnk.pl`.

The following doc is based on the original HTML doc file. I didn't any
effort to check if it is up to date and whatever else.


Doc for wlnk.pl
---------------

This Perl script tries to create a MS Windows Shortcut File (extension
.LNK).

### Usage

The program reads from standard input a description of the data of the
"link" and outputs to standard output the (binary) LNK file.

    wlnk.pl <desc.txt >shorcut.lnk

An example can be found inside the [fake directory](fake/).


### Description of the content of the descriptor file

The descriptor file contains the description of what we want to put
inside the LNK file. **The ShellItem ID List is not handled**.

The file contains keywords, always ending with `=`, that must be
written at the beginning of the line, and everything else after the
`=` is an argument. Strings are uninterpreted and unchanged, so spaces
before, during and after matter (the last character, which should be a
LineFeed, is chopped; if you have a CR LF pair, strip the CR by
yourself).

Other arguments could be evaluated as Perl expression, so be careful!
(No sand/safe box created.

* **basepath**: a base path, like `C:\Documents and Settings\User\Desktop`
* **showwnd**: allowed symbolic values are
  * SW_HIDE,
  * SW_NORMAL,
  * SW_SHOWMINIMIZED,
  * SW_SHOWMAXIMIZED,
  * SW_SHOWNOACTIVATE,
  * SW_SHOW,
  * SW_MINIMIZE,
  * SW_SHOWMINNOACTIVE,
  * SW_SHOWNA,
  * SW_RESTORE,
  * SW_SHOWDEFAULT
* **mainflag**: the expression is evaluated as a Perl code. The aim is
  to be able to write things like `(0x01 << 5)|1`. No symbolic
  help: you must know...
* **targetflag**: the expression is evaluated as a Perl code, like
  `mainflag`. No symbolic help.
* **workdir**: where an executable supposes to be when run
* **desc**: description
* **cmdline**: the command line
* **customicon**: the custom icon
* **iconindex**: the index of the icon; it is evaluated as Perl code
* **time1**: the format is `HL#LL` where the first letter (H or L)
  stands for High or Low. Both can be Perl expressions (this allows to
  write e.g. `0x56`
* **time2**: see `time1`
* **time3**: see `time2`
* **hotkey**: the hotkey (numeric value evaluated as Perl expression)
* **volumetype**: a symbolic string; accepted values
  * unknown,
  * noroot,
  * removable,
  * fixed,
  * remote,
  * cdrom,
  * ramdrive
* **volumelabel**: a string that is the label of the volume.
* **volumeserial**: a numeric value, evaluated as Perl expression.
* **length**: length of the target...? (numeric value evaluated as
  Perl expression)


### Example

This is the one inside the `fake` drawer. Not so useful.

    desc=This is a fake!
    basepath=C:\WINDOWS\system32\notepad.exe
    mainflag=(0x01 << 2) + (0x01 << 4 ) + (0x01 << 7)
    workdir=%HOMEDRIVE%%HOMEPATH%
    time1=0x09ABCDEE#0x4506A400
    time2=1#0
    time3=50606#993939
    volumelabel=HOME
    targetflag=1 + (0x01 << 5)
    length=156000


### Codes for mainflag (SHELL\_LINK\_DATA_FLAG)

    typedef enum {
        SLDF_HAS_ID_LIST = 0x00000001,
        SLDF_HAS_LINK_INFO = 0x00000002,
        SLDF_HAS_NAME = 0x00000004,
        SLDF_HAS_RELPATH = 0x00000008,
        SLDF_HAS_WORKINGDIR = 0x00000010,
        SLDF_HAS_ARGS = 0x00000020,
        SLDF_HAS_ICONLOCATION = 0x00000040,
        SLDF_UNICODE = 0x00000080,
        SLDF_FORCE_NO_LINKINFO = 0x00000100,
        SLDF_HAS_EXP_SZ = 0x00000200,
        SLDF_RUN_IN_SEPARATE = 0x00000400,
        SLDF_HAS_LOGO3ID = 0x00000800,
        SLDF_HAS_DARWINID = 0x00001000,
        SLDF_RUNAS_USER = 0x00002000,
        SLDF_HAS_EXP_ICON_SZ = 0x00004000,
        SLDF_NO_PIDL_ALIAS = 0x00008000,
        SLDF_FORCE_UNCNAME = 0x00010000,
        SLDF_RUN_WITH_SHIMLAYER = 0x00020000,
        SLDF_RESERVED = 0x80000000,
    } SHELL_LINK_DATA_FLAGS;


### Target flags

This cut fragment of code tells you about target flags.

    "is read only",  0x01 << 0 ;
    "is hidden",  0x01 << 1 ;
    "is a system file",  0x01 << 2 ;
    "is a volume label",  0x01 << 3 ;
    "is a directory",  0x01 << 4 ;
    "has been modified since last backup",  0x01 << 5 ;
    "is encrypted",  0x01 << 6 ;
    "is normal",  0x01 << 7 ;
    "is temporary",  0x01 << 8 ;
    "is a sparse file",  0x01 << 9 ;
    "has reparse point data",  0x01 << 10 ;
    "is compressed",  0x01 << 11 ;
    "is offline",  0x01 << 12 ;


Notes
-----

In the code you can read:

> WIDELY BASED UPON Jesse Hager's reverse-engineered document about
> Windows Shortcut File Format.

But I hadn't added a link. Searching for him, I've found the PDF, [The Windows Shortcut File format](https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/8bits/The_Windows_Shortcut_File_Format.pdf), but also [these informations](https://github.com/libyal/liblnk/blob/master/documentation/Windows%20Shortcut%20File%20%28LNK%29%20format.asciidoc) (Hager is given in the *references appendix*).

My code was mostly a way to insert raw data into a LNK file, not a
user friendly way to create such a file format (e.g. you must handle
timestamp/date by yourself). Moreover, it seems it doesn't work well: `exiftool`
outputs gibberish as *description*, instead of `This is a fake!`; `lnk-parse.pl`
says that *description* is `Null`.

Actually it seems like `elnk.pl` is the only one who can read the
*description*.
