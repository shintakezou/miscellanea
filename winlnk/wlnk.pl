#! /usr/bin/perl

# Try to create a LNK file according to an ASCII
# file you pass through STDIN.

# WIDELY BASED UPON Jesse Hager's reverse-engineered document
# about Windows Shortcut File Format.


use Encode qw/encode decode/;
use Getopt::Long;

%showwndarr = ( "SW_HIDE" => 0, "SW_NORMAL" => 1, "SW_SHOWMINIMIZED" => 2,
             "SW_SHOWMAXIMIZED" => 3, "SW_SHOWNOACTIVATE" => 4, "SW_SHOW" => 5,
             "SW_MINIMIZE" => 6, "SW_SHOWMINNOACTIVE" => 7,
             "SW_SHOWNA" => 8, "SW_RESTORE" => 9, "SW_SHOWDEFAULT" => 10);

%voltype = (
      "unknown" => 0, "noroot" => 1, "removable" => 2, "fixed" => 3, "remote" => 4,
      "cdrom" => 5, "ramdrive" => 6
       );



sub vstring
{
  ( $s, $t ) = (shift, shift);
  chop($s); chomp($s);
  if ( $t < 2 )
  {
    return $s;
  } else {
    my $temp = encode("UCS-2LE", $s);
    return $temp;
  }
}


sub debug
{
  printf STDERR "*** debug: %s\n", shift;
}

sub Help
{
  print "wlnk.pl

wlnk.pl creates a LNK binary file according to infos given from STDIN
(see the html doc for more)";
  exit 1
}

GetOptions( "help|h|?" => sub { Help; } );

my $description = ""; #desc=STRING
my $fullpath = ""; # basepath=STRING
my $showwnd = "SW_NORMAL"; #showwnd=STRING in @showwnd
my $mainflag; #headerflag=VALUE
my $fl=0;
my $workdir = ""; #workdir=STRING
my $commandline = ""; #commandline=STRING
my $customicon = ""; #customicon=STRING
my $iconindex = pack("L",0); #iconindex=VALUE
my $time1;  #time1=VALUE#VALUE
my $time2;  #time2=VALUE#VALUE
my $time3;  #time3=VALUE#VALUE
my $hotkey = pack("L",0); #hotkey=VALUE
my $volumetype="fixed"; #volumetype=STRING in @voltype
my $volumeserial = pack("L",0); #volumeserial=VALUE
my $volumelabel="LABEL"; #volumelabel=STRING
my $length=0; #length=VALUE;
my $targetflag=pack("L",0); #targetflag=VALUE
my $tg=0;

while ( <STDIN> )
{
  if ( /^basepath=/ )
  {
    s/^basepath=//;
    $fullpath=$_; next;
  }
  if ( /^showwnd=/ )
  {
    s/^showwnd=//;
    $showwnd = $_; next;
  }
  if ( /^mainflag=/ )
  {
    s/^mainflag=//;
    $fl = eval($_);
    next;
  }
  if ( /^targetflag=/ )
  {
    s/^targetflag=//;
    $tg = eval($_);
    next;
  }
  if ( /^workdir=/ )
  {
    s/^workdir=//;
    $workdir=$_; next;
  }
  if ( /^desc=/ )
  {
    s/^desc=//;
    $description=$_; next;
  }
  if ( /^cmdline=/ )
  {
    s/^cmdline=//;
    $commandline=$_; next;
  }
  if ( /^customicon=/ )
  {
    s/^customicon=//;
    $customicon=$_; next;
  }
  if ( / ^iconindex=/ )
  {
    s/^iconindex=//;
    $iconindex=pack("L",eval($_)); next;
  }
  if ( /^time1=(.*)#(.*)$/ )
  {
    debug "$1 -- $2 ;; " . eval($1) . " ;; " . eval($2);
    $time1=pack("L", eval($1)) . pack("L", eval($2));
    next;
  }
  if ( /^time2=(.*)#(.*)$/ )
  {
    $time2=pack("L", eval($1)) . pack("L", eval($2)); next;
  }
  if ( /^time3=(.*)#(.*)$/ )
  {
    $time3=pack("L", eval($1)) . pack("L", eval($2)); next;
  }
  if ( /^hotkey=/ )
  {
    s/^hotkey=//;
    $hotkey=pack("L",eval($_)); next;
  }
  if ( /^volumetype=/ )
  {
    s/^volumetype=//;
    $volumetype=$_; next;
  }
  if ( /^volumelabel=/ )
  {
    s/^volumelabel=//;
    $volumelabel=$_; next;
  }
  if ( /^volumeserial=/ )
  {
    s/^volumeserial=//;
    $volumeserial=pack("L",eval($_)); next;
  }
  if ( /^length=/ )
  {
    s/^length=//; $length = eval($_); next;
  }
}

if ( ! exists $showwndarr{$showwnd} )
{
  $showwnd = "SW_NORMAL";
}
if ( ! exists $voltype{$volumetype} )
{
  $volumetype= "fixed";
}

print STDERR "** SHOWWND SYMB $showwnd\n" .  "** SHOWWND NUM ". $showwndarr{$showwnd} . "\n";
$showwnd = pack("L",$showwndarr{$showwnd});
$volumetype = pack("L", $voltype{$volumetype});
   $fl = ($fl & ~(0x200 | 0x8)) | 0x2;
       # force some flag and delete others... depending on what is supportend
       # and what is not.
    $mainflag=pack("L",$fl);
   $targetflag=pack("L",$tg); #no check

chop($volumelabel);
chop($fullpath);
chop($description);
chop($workdir);
chop($commandline);
chop($customicon);

if ( ! $fullpath )
{
  die "a basepath= must be present!";
}

$len = pack("L", $length);

# head
print "\x4C\x00\x00\x00";
# guid
print pack("L", 0x21401) . "\x00\x00\x00\x00" . pack("S", 0xC0) .
      "\x00\x00\x00\x00\x00\x46";
# main flag
print $mainflag;
# attrib
print $targetflag;
# times
$zerotime = pack("L",0) . pack("L",0);
if ( length($time1) > 0 )
{
  print $time1;
} else { print $zerotime; }
if ( length($time2) > 0)
{
  print $time2;
} else { print $zerotime; }
if ( length($time3) > 0)
{
  print $time3;
} else { print $zerotime; }

# length
print $len;

# icon index
print $iconindex;

# showwnd
print $showwnd;

# hotkey
print $hotkey;

# ???
print pack("L",0);
print pack("L",0);


# compute size of file location info
my $scala=1;
if ( ($fl & (0x01 << 7) ) ) { $scala = 2; }
$a = 0x1c + 0x10 + length($volumelabel)+1 + (length($fullpath)+1) +
     1;
$tot=$a;
# write out len
print pack("L", $a);


# first offset after struct:
print pack("L", 0x1C);

# available on a local (no network support)
print pack("L", 0x01);


# compute offset of local volume info...
$a = 0x1c;   # fixed since I put no more in here
print pack("L", $a);


# offset of base path name
$a = 0x1c + 0x10 + length($volumelabel)+1;
print pack("L", $a);

# network no
print pack("L", 0);

# offset remaining
print pack("L", $tot - 2);


# volume table ----------
# length
print pack("L", 0x10 + length($volumelabel)+1);

# type
print $volumetype;
# serial
print $volumeserial;

# offset
print pack("L", 0x10);

# volumelabel
print $volumelabel . "\x00";


# fullpath -- never UNICODE
# if ( $scala < 2 )
  print $fullpath . "\x00";
# } else {
#   $enc = encode("UCS-2LE", $fullpath);
#   print pack("a*", $enc);
#   print "\x00\x00";
# }

if ( $fl & (0x01 << 2) )
{
  $d = vstring($description,$scala);
  print pack("S", length($d)/$scala);
  # printf STDERR "*** %s %d\n", $description, length($d);
  print pack("a*",$d);
}

if ( $fl & (0x01 << 4) )
{
  $d = vstring($workdir,$scala);
  print pack("S", length($d)/$scala);
  print pack("a*", $d);
}

if ( $fl & (0x01 << 5) )
{
  $d = vstring($commandline,$scala);
  print pack("S", length($d)/$scala);
  print pack("a*", $d);
}

if ( $fl & (0x01 << 6) )
{
  $d = vstring($customicon,$scala);
  print pack("S", length($d)/$scala);
  print pack("a*", $d);
}

# end
print pack("L", 0);

exit 0;
