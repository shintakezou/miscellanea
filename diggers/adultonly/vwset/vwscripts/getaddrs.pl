#!/usr/bin/perl -w

use strict;

while (<>)
{
 my @severale = split(/>(.*)</);
 for (@severale) {
   if (/
    (
      <(a)\b   # taken from lwp-rget.pl
      [^>]+
      \b(href)
      \s*=\s*
    )
      (?:				    # scope of OR-ing
	   (")([^"]*)"	|	    # value in double quotes  OR
	   (')([^']*)'	|	    # value in single quotes  OR
	      ([^\s>]+)		    # quoteless value
      )
/gix) { print "$5\n"; }
  }
}
