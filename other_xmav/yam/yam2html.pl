#! /usr/bin/perl

##     yam2html.pl - converts Amiga YAM mailer address book to HTML
##     Copyright (C) 2007  Mauro Panigada
##
##     This program is free software; you can redistribute it and/or modify
##     it under the terms of the GNU General Public License as published by
##     the Free Software Foundation; either version 2 of the License, or
##     (at your option) any later version.
##
##     This program is distributed in the hope that it will be useful,
##     but WITHOUT ANY WARRANTY; without even the implied warranty of
##     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##     GNU General Public License for more details.
##
##     You should have received a copy of the GNU General Public License
##     along with this program; if not, write to the Free Software
##     Foundation, Inc., 51 Franklin Steet, Fifth Floor, Boston, MA  02111-1307  USA

$sign = <STDIN>;

if ( $sign !~ /^YAB.\s- YAM Addressbook/ )
{
  print STDERR "This seems not a YAM Addressbook\n";
  exit 1
}


my $group = 0;
my %nicklist;

print <<EOT
<html><head><title>YAM Addressbook</title>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style>
h1 { text-align: center}
h2 { color: black; background-color: #AA9988; margin-bottom:0px;
     padding-left: .5em}
ul { border: 1px solid #AA9988}
ul.cola { background-color: #FFDFDF}
ul.colb { background-color: #DFDFFF}
</style>
</head>
<body>
<h1>YAM Addressbook</h1>
EOT
;

print STDERR "Reading addressbook...\n";
$group=0;

print "<ul style=\"background-color:#DFFFDF\">\n";

while(<STDIN>)
{
  if ( /^\@GROUP\s(.+)$/ )
  {
    $group++;
    my $t = $1;
    chop($t); chomp($t);
    if ( ($group % 2) eq 0 )
    {
      $col = "cola";
    } else {
      $col = "colb";
    }
    print "<h2>$t</h2>\n<ul class=\"$col\">\n";
  }
  if ( /^\@ENDGROUP/ )
  {
    $group--;
    print "</ul>";
  }
  next if /^\s*$/;
  if ( /^\@USER\s(.+)$/ )
  {
     my $u = $1;
     my $indirizzo = <STDIN>;
     my $un = <STDIN>;
     if ( $un =~ /^\s*$/ ) { $un = $u; }
     chomp($u); chomp($un); chomp($indirizzo);
     chop($u); chop($un); chop($indirizzo);
     print "<li><a name=\"$u\"></a><a href=\"mailto:$indirizzo\">$un</a> ($u)</li>\n";
  }
  if ( /^\@LIST\s(.+)$/ )
  {
     my $u = $1;
     chop $u;
     chomp $u;
     print "<li><b>LIST <a name=\"$u\">$u</a></b>: ";
     QUE: while (<STDIN>)
     {
       next if ( /^\s*$/ );
       last QUE  if ( /^\@ENDLIST\s*/ );
       my $n = $_; chomp $n; chop $n;
       print "<a href=\"#$n\">$n</a> "
     }
     print "</li>\n";
  }
}

print "</ul></body></html>\n";

if ( $group ne 0 )
{
  print STDERR "Uncorrect grouping!\n";
}

exit 0
