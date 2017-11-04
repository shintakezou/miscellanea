#!/usr/bin/perl -w

use strict;

while (<>)
{
  s/\x0D/\n/gi;
  print;
}
