#! /usr/bin/perl

use strict;

my $estratto = 0;

if ( $#ARGV < 0 )
{
  die "specify a file...\n";
}

my $sourcefile = $ARGV[0];
my $destfile = "";
if ( $#ARGV > 0 )
{
   $destfile = $ARGV[1];
}

open(INPUT, "<", $sourcefile) or die "cannot open $sourcefile\n";
my $buf = "";
read INPUT,$buf,8;
if ( $buf ne "\x89\x50\x4E\x47\x0D\x0A\x1A\x0A" )
{
   die "not a PNG\n";
}

while(1)
{
   my $res = read(INPUT, $buf, 4);   # length of chunk
   last if $res == 0;
   if ( $res == undef )
   {
      die "An error occurred while reading...\n";
   }
   my $lengthofchunk = unpack("N", $buf);
   read(INPUT, $buf,4);   # chunk
   if ( $buf eq "IEND" ) {
       print "End chunk found\n";
       last;
   }
   # changing this to another tag, and avoiding the skipping of 11 bytes
   # of the MSOFFICE sign, you have implemented simply a chunk extractor!
   if ( $buf eq "msOG" ) {
       if ( $destfile eq "" )
       {
          $destfile = $sourcefile . ".gif";
       }
       print "Found the silly Microsoft msOG chunk; extracting to \"$destfile\"...\n";
       open(OUTPUT, ">", $destfile) or die "cannot create $destfile\n";
       seek INPUT, 11, 1; # skip MSOFFICE1.1 or similar
       if ( $lengthofchunk <= 11 )
       {
          die "the msOG chunk's length should be greater than 11!\n";
       }
       read(INPUT,$buf,$lengthofchunk-11) or die "reading chunk msOG error!\n";
       print OUTPUT $buf; # works?
       close(OUTPUT);
       $estratto = 1;
       last;
   }
   seek(INPUT, $lengthofchunk+4, 1);  # skip this chunk and CRC
}
close(INPUT);

if ( $estratto == 0 )
{
   print "The chunk msOG is not inside this file\n";
} else {
   print "msOG chunk extracted successfully\n";
}

exit 0;
