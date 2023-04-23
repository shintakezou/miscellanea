#!/usr/bin/perl -w

# GPL stuffs here
# (C)2006 Mauro Panigada

#tool that transforms a single line html full <a> tag in a csv table, using
#tab as separator instead of comma or what.

# usage:
#  cat file.html |addrcsv.pl
#  addrcsv.pl <file.html
#
# Recognises nohtml as option:
#  addrcsv.pl nohtml <file.html
#
# It is not 100% safe; scripts into html or other structures can be
# confunding...
#

sub scrivilo {
  my ( $stringa, $nohtml ) = @_;
  if ( $nohtml == 0 )
  {
    print "$stringa\n";
  } else {
    $stringa =~ s/<[^>]*>//g;
    print "$stringa\n";
  }
}

my $nohtml=0;
if ( $#ARGV > -1 )
{
 if ( "$ARGV[0]" eq "nohtml" )
 {
   $nohtml=1;
 }
}
while(<STDIN>)
{
  chomp;
  my $app=$_;
  if (! s/<a\s*.*[hH][rR][eE][fF]\s*=\s*"([^"]*)"[^>]*>(.*)<\/a>/$1\t$2/ )
  {
    $app=~s/<a\s*.*[hH][rR][eE][fF]\s*=\s*'([^']*)'[^>]*>(.*)<\/a>/$1\t$2/;

    scrivilo ($app, $nohtml);
    next;
  }
  scrivilo ($_, $nohtml);
}
