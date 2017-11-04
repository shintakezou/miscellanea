#!/usr/bin/perl

# GPL
# (C)2006 Mauro Panigada

# extracts content from a MIME encoded file. Easy as it seems using
# MIME::Parser!!
#
# BUT BECARE YOU WINDOWS USER!
# I try to make ordered dir classifying files by type. And this do I
# using tool like mmv (Multiple MoVe) that is likely to appear on
# a GNU/Linux machine... Then I use my own linkall.pl to change
# links so that everything works despite of moving all around.
#
# comment or delete from
# "rough machilage" comment to the end in order to leave things as they are
#

use MIME::Parser;

my $p = new MIME::Parser;
my $ddir;

die "specify a file\n" if ( $#ARGV < 0);

if ( $#ARGV >= 1 ) {
  mkdir $ARGV[1] if ( ! -e $ARGV[1] );
  -d $ARGV[1] or die $ARGV[1]." must be a dir\n";
  $ddir = $ARGV[1];
} else {
   $ddir = "./";
}

$p->output_dir("$ddir");
$p->output_prefix("__"); # should not appear

  -f $ARGV[0] or die $ARGV[0]." not a file or does not exist\n";
  $p->parse_open($ARGV[0]);

#rough machilage
mkdir "$ddir/img";
mkdir "$ddir/css";
mkdir "$ddir/js";
`mmv "$ddir/*.[jJ][sS]" "$ddir/js"`;
`mmv "$ddir/*.[pP][nN][Gg]" "$ddir/img"`;
`mmv "$ddir/*.[jJ][pP][gG]" "$ddir/img"`;
`mmv "$ddir/*.[jJ][pP][eE][gG]" "$ddir/img"`;
`mmv "$ddir/*.[Gg][iI][fF]" "$ddir/img"`;
`mmv "$ddir/*.[cC][sS][sS]" "$ddir/css"`;
`mmv "$ddir/*.[iI][cC][oO]" "$ddir/img"`;
`linkall.pl "$ddir"`;

exit;

