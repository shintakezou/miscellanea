#!/usr/bin/perl -w

# Released under GPL bla bla
# (C)2006 Mauro Panigada

# extracts href from a specified html file. sometimes can fail
# (parser's fault not mine!:-), often does the job

# usage:
#    ghreff.pl filename.html

use strict;
use HTML::Parser ();

my %inside;
my %aattr;

sub tag
{
  my ($tag, $attr, $num) = @_;
  $inside{$tag} += $num;
  if ( defined ($attr) ) {
    if ( $tag eq 'a' ) {
      %aattr = %$attr;
    }
  }
}

sub text
{
  #return if ! $inside{a} || $inside{script} || $inside{style};
  return if !defined ($inside{a});
  return if defined($inside{script}) && ($inside{script}>0);
  return if defined($inside{style})  && ($inside{style} >0);
  $_[0] =~ s/^\s*//g;
  $_[0] =~ s/\s*$//g;
  $_[0] =~ s/\r*//g;
  $_[0] =~ s/\n*//g;
  $_[0] =~ s/\t+/ /g;
  $_[0] =~ s/ [ ]+/ /g;
  $_[0] =~ s/[^A-Za-z0-9_ ]*//g;
  print "$aattr{href}\t\"$_[0]\"\n" if defined $aattr{href};
  $aattr{href} = undef;
}


  HTML::Parser->new(api_version => 3,
                  handlers    => [start => [\&tag, "tagname, attr, '+1'"],
                                  end   => [\&tag, "tagname, attr, '-1'"],
                                  text  => [\&text, "dtext"],
                                 ],
                  marked_sections => 1,
                 )->parse_file(shift) || die "error: $!\n";
