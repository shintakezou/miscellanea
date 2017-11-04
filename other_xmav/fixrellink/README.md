fixrellink.sh
=============

What is
-------

The Bash script `fixrellink.sh` is a little bash script (!) that
has the aim of “fixing” relative links and making them absolute.
Relative links need to be fixed when you move the folder containing
them so that the parent of that folder is not the same as before and
the links “pointed” outside the folder they are.


Why and when to use fixrellink.sh
---------------------------------

You maybe would feel the need of this script only if you cannot,
for any reason, use the `mount --bind`!
See below for a fast solution using the `--bind` option to mount.

When you copy with the `cp -a` (or with the preserve links option)
then you obtain a sort of *exact* copy of the content of the folder.
The softlinks are not resolved, they are copied as they are. This saves
rooms but in the same time, if the parent of the folder you are copying
is not the same, relative links could not work anymore.

This is why you maybe need `fixrellink.sh`: you “moved”
(preserving attributes and links) a folder containing relative softlinks
and now some of them do not point at the right place since the parent
of the moved folder is not the same as before.

`fixrellink.sh` can help you.


How
---

`fixrellink.sh` read softlinks and check if they are not absolute
and it they point out of the containing folder. If this is true, it makes
them absolute, using as parent the one you specify.

Usage
-----

    fixrellink.sh FOLDER PARENT ROLLBACKFILE

    fixrellink.sh --rollback ROLLBACKFILE

These arguments are mandatory.

<dl>
  <dt>FOLDER</dt>
  <dd>
     specify the FOLDER where the softlinks are. This is the <strong>new</strong>
     folder, but it could be the old one too, before moving/copying
     it. It works the same. <strong>Use absolute path!</strong>
  </dd>
  <dt>PARENT</dt>
  <dD>
     The old parent of the folder, the folder that once contained the
     moved folder. <strong>Use absolute path!</strong>
  </dd>
  <dt>ROLLBACKFILE</dt>
  <dd>
      A file where to save the modified links and their original, so that
      you can <em>rollback</em> if something seems to go wrong.
  </dd>
</dl>


Problems
--------

You could not modify (delete and create) a link if you are not the
owner of, or if you have no the rights. Attributes like creation time,
or ownership and so on are not preserved nor restored when you roll
back. You **must** run `fixrellink.sh` as the user you want
to appear as the owner of the link. That owner should have the rights
to write/delete the links inside that folder.

Don't forget that your rights to the access of the object pointed
by the link depends on the rights of the object, not on the rights
of the link.


If you are fixing *system* things (like the case that suggested
me to create this script) run it as root.

The script does some checking, but of course I am not responsible
for any damage, loss of data, ... or anything else.

**Use it at your own risk**. Rollback can fix the things back, but
remember that original creation time and ownership/group of the links
**are not** restored. If something relies on that to work properly,
avoid using `fixrellink.sh`.


Final note
----------

The use of this script is easy, so no more words are needed. Be sure
to understand the most important points and the fact that if something
goes wrong I am not responsible of it. Use it at your own risk.

(Deleting links is not like deleting real file, so your data should not
be lost, but if you are not able to fix problems, do not complain with
me or with `fixrellink.sh`)


Why you don't need fixrellink.sh
--------------------------------

... but anyway it still is an interesting script, isn't it? ...

The `--bind` option of the mount program kills
`fixrellink.sh` of course. The solution is so easy... I give
you the steps taking as example my case.


    # cp -aR /usr/share /mnt/ext/ext_share
	
Check everything's fine before to take the next step.

    # rm -R /usr/share
    # mkdir /usr/share
    # mount --bind /mnt/ext/ext_share /usr/share
    # echo "/mnt/ext/ext_share /usr/share none rw,bind 0 0" >>/etc/fstab

The next time you reboot, you should have your `/usr/share`
as if it were exactly where it was.

