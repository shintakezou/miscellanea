#!/usr/bin/perl -w

# usage:
#   dothumb.pl FILE YSIZE

use Image::Imlib2;

if ( @ARGV > 1 )
{
  my $image = Image::Imlib2->load($ARGV[0]);
  if ( $image )
  {
    my $thumb = $image->create_scaled_image(0,$ARGV[1]);
    $ARGV[0] =~ s/(.*)\.(.*)/$1_th.$2/ ;
    $thumb->save($ARGV[0]);
  }
} else {
  die "argument missing\n";
}
