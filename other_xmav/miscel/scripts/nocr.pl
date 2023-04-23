#!/usr/bin/perl -w

# filter out CR from file

# use:
# cat xyz |nocr.pl

use strict;

while (<>)
{
  s/\x0D/\n/gi;
  print;
}
