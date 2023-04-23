#!/usr/bin/perl -w

# extracts the search result from a Google search page;
# this is easy thank to google guys using comments to mark the results

#undef $/;

while (<>) {
    m/<\!--m-->(.*)<\/a><font/;
    if ( defined $1 )
    {
      print "$1</a>\n";
    }
}
