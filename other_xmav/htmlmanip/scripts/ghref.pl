#!/usr/bin/perl -w

# Released under GPL bla bla
# (C)2006 Mauro Panigada

# extracts href from input (supposed html!). sometimes can fail
# (parser's fault not mine!:-), often does the job
# (take a look at ghreff.pl too)

# usage:
#    ghref.pl <filename.html
#    cat pippo.html topo.html |ghref.pl

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
  #print "$inside{a}\n" if defined $inside{a};
  #print "$inside{script}\n" if defined $inside{script};
  #print "$inside{style}\n" if defined $inside{style};
  return if !defined ($inside{a});
  return if defined($inside{script}) && ($inside{script}>0);
  return if defined($inside{style})  && ($inside{style} >0);
  #chomp($_[0]);
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

while(<STDIN>)
{
  HTML::Parser->new(api_version => 3,
                  handlers    => [start => [\&tag, "tagname, attr, '+1'"],
                                  end   => [\&tag, "tagname, attr, '-1'"],
                                  text  => [\&text, "dtext"],
                                 ],
                  marked_sections => 1,
                 )->parse($_) || die "error: $!\n";
}