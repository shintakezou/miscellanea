updatesite.sh
=============

I am always trying to do things automagically. Since I started caring
about other sites of mine, I needed a more general tool. You should
consider this a work-in-progress script.

Basics
------

First, your sites must be inside `$HOME/public_html`, one folder per
site. E.g. if you maintain two sites, say your personal one and your
friend's one, you create two folder: `personal` and `friend`.

Inside each folder you create a hidden folder called simply
`.admin`. This folder must contain some data. First of all, all data
about the connection, so that the script can connect to your ftp
server.

Then you will put here other things according to your administrative
needs.

Connection data are stored inside `Connect` file. The file `UPDATE`
contains the list of things to be uploaded/updated.

The script uses this list to build a file where there are commands for lftp
(I suppose you can use another ftp client too). These commands are executed
if you add the option `exec` as second argument for the script.
Otherwise they are simply sent to the output.

The content of `UPDATE` is very simple: a list of files to be updated!
You can use wildcards (`*` and `{}`), and give direct command to lftp;
this is useful when you need to create new folders or do some other
special task (deleting, renaming and so on). Just put a `!` as first
character of the line.

When the script finished, it writes the file `LastUpdate`, inside
there is the date in ISO-8601 format. Anyway, the last modification
time of the file or its content can be used by other tools in order to
check when the last online update was done.  Then it rename the
`UPDATE` file into `UPDATE.YYYYMMDD`. So you can find problem if you
do more than once online update per day.

See the [admin-ex](admin-ex/) folder for an example (and the output of
the script that you can see if you do not add the `exec` option).

