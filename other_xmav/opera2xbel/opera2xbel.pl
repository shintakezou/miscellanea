#! /usr/bin/perl

# convert Opera6 adr (bookmarks) into XBEL
# not so "polished"
#
# do not treat in special way the Trash folder.
#

use URI::Escape;
use HTML::Entities;

my $firstline = <STDIN>; # Opera Hotlist version 2.0
my $secondline = <STDIN>; # Options: encoding = utf8, version=3

if ( $firstline !~ /^Opera Hotlist version (\d+)\.(\d+)/ )
{
    die "it seems not a Opera Hotlist file\n";
}

if ( $1 < 2 )
{
   print STDERR "*** this is version $1 of Opera Hotlist: I am programmed for version 2\n";
   print STDERR "*** I will continue anyway\n";
}
if ( ($1 == 2) && ( $2 != 0 ) )
{
   print STDERR "*** this is revision $2 of Opera Hotlist: I am programmed for revision 0\n";
   print STDERR "*** I will continue anyway\n";
}

print STDERR "*** Ignoring option line saying:\n";
print STDERR "$secondline\n";


print <<EOTUS
<?xml version="1.0" standalone="yes" ?>
<!DOCTYPE xbel
          PUBLIC "+//IDN python.org//DTD XML Bookmark Exchange Language 1.0//EN//XML"
                 "http://www.python.org/topics/xml/dtds/xbel-1.0.dtd">
<xbel version="1.0" added="2007-10-08T10:48:21+0200">
  <title>Bookmarks</title>
EOTUS
;

my $flv = 0;
my %url = ();
my $inurl = 0;


while ( <STDIN> )
{
    next if /^$/;
    chomp;
    if ( /^#FOLDER/ )
    {
        if ( $inurl != 0 )
        {
            emiturl();
            $inurl = 0;
            %url = ();
        }
        print "\t" x $flv;
        print "<folder folded=\"no\">\n";
        $flv++;
        next;
    }
    if ( /^\tNAME=(.*)$/ )
    {
        if ( $inurl == 0 )
        {
          print "\t" x $flv;
          print "<title>$1</title>\n";
        } else {
          $url{'name'} = $1;
        }
        next;
    }
    if ( /^-/ )
    {
        if ( $inurl == 1 )
        {
            emiturl();
            $inurl = 0;
            %url = ();
        }
        $flv--;
        print "\t" x $flv;
        print "</folder>\n";
        next;
    }
    if ( /^#URL/ )
    {
        if ( $inurl == 1 )
        {
           emiturl();
        }
        %url = ();
        $inurl = 1; next;
    }
    if ( /^\tURL=(.*)$/ && ($inurl==1))
    {
        $url{'url'} = $1;
        next;
    }
    if ( /^\tDESCRIPTION=(.*)$/ && ( $inurl==1) )
    {
        $url{'desc'} = $1;
        next;
    }
}
print "</xbel>";

sub emiturl
{
    print "\t" x $flv;
    my $theurl;
    if ( $url{'url'} =~ m|^javascript:| )
    {
       $theurl = uri_escape(encode_entities($url{'url'},"&<>"), '"');
    } else {
       $theurl = uri_escape(encode_entities($url{'url'},"&<>"), '<> "');
    }
    print "<bookmark href=\"" . $theurl . "\" added=\"\" modified=\"\" visited=\"\">\n";
    print "\t" x ($flv + 1);

    print "<title>" . encode_entities($url{'name'}, "<>&") . "</title>\n";
    print "\t" x ($flv + 1);
    print "<desc>" . $url{'desc'} . "</desc>\n";
    print "\t" x $flv;
    print "</bookmark>\n";
}

exit 0;
