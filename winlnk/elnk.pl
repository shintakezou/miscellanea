#! /usr/bin/perl

# WIDELY BASED UPON Jesse Hager's reverse-engineered document
# about Windows Shortcut File Format.

# 2007-06-14:     added -e option to extract itemidlist in sep files.

use Encode qw/encode decode/;
use Getopt::Long;

@showwnd = ( "SW_HIDE", "SW_NORMAL", "SW_SHOWMINIMIZED",
             "SW_SHOWMAXIMIZED", "SW_SHOWNOACTIVATE", "SW_SHOW",
             "SW_MINIMIZE", "SW_SHOWMINNOACTIVE",
             "SW_SHOWNA", "SW_RESTORE", "SW_SHOWDEFAULT" );

@voltype = (
      "unknown", "no root directory", "removable", "fixed", "remote",
      "cd-rom", "ram drive"
       );

my $extract;

sub debug
{
  printf STDERR "*** debug: %s\n", shift;
}

sub Help
{
  print "elnk.pl [OPTS] FILENAME

elnk.pl extracts info from a Microsoft Windows LNK file.
LNK's specs are reversed engineered so don't complain if
something gets wrong.

Options:
\t-e
\t--extract\t\textracts ShellItem List to LNK_PATH/LNK_NAME.sii[0-9]+\n";
  exit 1
}

sub get4
{
  my $file = shift;
  my $temp;
  my $len = read($file, $temp, 4) || die "Error reading";
  if ( $len < 4 ) { die "format/reading error"; }
  $temp = unpack("L", $temp);
  return $temp;
}

sub getvstring
{
  my $temp;
  my $file = shift;
  my $re = read($file, $temp, 2) || die "Error reading";
  if ( $re < 2 ) { die "Premature end of file!"; }
  my $len = unpack("S", $temp);
  my $str;
  read($file, $str, ($unicoded ne 0 ) ? $len*2 : $len);
  #$str =~ s/\x00//g;
  if ($unicode eq 0)
  {
    return $str;
  } else {
    # suppose for Unicode they mean UCS-2 (LittleEndian), rather than
    # UTF-16
    return decode("UCS-2LE",$str);
  }
}

sub yesno
{
  $val = shift;
  return ( $val ne 0) ? "yes" : "no";
}

sub gentarget
{
  ( $testo, $val ) = @_;
  printf "Target $testo: %s\n", yesno($val);
}




# =========================================================================

GetOptions( "e|extract" =>  \$extract,
            "h|?|help" => sub { Help; } );

if ( $#ARGV < 0 ) { Help; }

open(FILE, "<", $ARGV[0]) || die "Cannot open file " . $ARGV[0];
binmode(FILE);


printf "Analysing \"%s\"\n\n", $ARGV[0];

# header 4C000000
$letti = read(FILE, $dat, 4) || die "Error reading";
if ( $letti < 4 || ($dat ne "\x4C\x00\x00\x00") )
{
  die "Cannot be a LNK file because of header";
}
undef $dat;


# get GUID: shell GUID should be
# (forgetting Little Endian invertion: bytes are read as they are!)
# 01 14 02 00 00 00 00 00 C0 00 00 00 00 00 46
$letti = read(FILE, $dat, 16) || die "Error reading";
if ( $letti < 16 )
{
  die "premature end";
}
if ( $dat ne "\x01\x14\x02\x00\x00\x00\x00\x00\xC0\x00\x00\x00\x00\x00\x00\x46" )
{
  print STDERR "GUID does not match, maybe not a LNK I can understand, I go on anyway\n";
}
undef $dat;


# flags
$letti = read(FILE, $flags, 4) || die "Error reading";
if ( $letti < 4 )
{
  die "Corrupted or shadowed LNK file?";
}

# bit 0: shell item id list yes/no
#     1: points to file/dir y/n
#     2: has description string y/n
#     3: has relative path string y/n
#     4: has working directory y/n
#     5: has command line argument y/n
#     6: has custom icon y/n

# for the little-endiannes of the intel arch which hosts Windows we
# have YY000000 where YY contains the bit we are interested in;
# to make it clear, I unpack it, so Perl copes with endiannes...
$fl = unpack("L", $flags);


$shellitem = $fl & (0x01 << 0);
$tofiledir = $fl & (0x01 << 1);
$description = $fl & (0x01 << 2);
$relativepath = $fl & (0x01 << 3);
$workingdir = $fl & (0x01 << 4);
$commandline = $fl & (0x01 << 5);
$customicon = $fl & (0x01 << 6);
$unicoded = $fl & (0x01 << 7);

$forcenolink = $fl & (0x100);
$has_exp_sz = $fl & (0x200);
$run_in_separate = $fl & (0x400);

$logo3d = $fl & (0x800);
$darwinid = $fl & (0x1000);
$runasuser = $fl & (0x2000);

$iconexpsz    = $fl & (0x4000);
$nopidlalias   = $fl & (0x8000);
$forceuncname  = $fl & (0x10000);
$withshimlayer = $fl & (0x20000);

# From winehq includes.
# typedef enum {
#     SLDF_HAS_ID_LIST = 0x00000001,
#     SLDF_HAS_LINK_INFO = 0x00000002,
#     SLDF_HAS_NAME = 0x00000004,
#     SLDF_HAS_RELPATH = 0x00000008,
#     SLDF_HAS_WORKINGDIR = 0x00000010,
#     SLDF_HAS_ARGS = 0x00000020,
#     SLDF_HAS_ICONLOCATION = 0x00000040,
#     SLDF_UNICODE = 0x00000080,
#     SLDF_FORCE_NO_LINKINFO = 0x00000100,
#     SLDF_HAS_EXP_SZ = 0x00000200,
#     SLDF_RUN_IN_SEPARATE = 0x00000400,
#     SLDF_HAS_LOGO3ID = 0x00000800,
#     SLDF_HAS_DARWINID = 0x00001000,
#     SLDF_RUNAS_USER = 0x00002000,
#     SLDF_HAS_EXP_ICON_SZ = 0x00004000,
#     SLDF_NO_PIDL_ALIAS = 0x00008000,
#     SLDF_FORCE_UNCNAME = 0x00010000,
#     SLDF_RUN_WITH_SHIMLAYER = 0x00020000,
#     SLDF_RESERVED = 0x80000000,
# } SHELL_LINK_DATA_FLAGS;



printf "Link has shell item id list: %s\n", yesno($shellitem);
printf "Link points to a file or dir: %s\n", yesno($tofiledir);
printf "Link has a description string: %s\n", yesno($description);
printf "Link has relative path string: %s\n", yesno($relativepath);
printf "Link has a working directory: %s\n", yesno($workingdir);
printf "Link has a command line argument: %s\n", yesno($commandline);
printf "Link has a custom icon: %s\n", yesno($customicon);
printf "Link data are in UNICODE (!): %s\n", yesno($unicoded);
printf "Link has force no link info flag (?): %s\n", yesno($forcenolink);
printf "Link has expanded size (?): %s\n", yesno($has_exp_sz);
printf "Link has run in separate flag (?): %s\n", yesno($run_in_separate);
printf "Link has logo 3d (?): %s\n", yesno($logo3d);
printf "Link has darwin id (?): %s\n", yesno($darwinid);
printf "Link has run as user flag (?): %s\n", yesno($runasuser);
printf "Link has icon expanded size (?): %s\n", yesno($iconexpsz);
printf "Link has no PIDL alias flag (?): %s\n", yesno($nopidlalias);
printf "Link has force UNiCode name flag (?): %s\n", yesno($forceuncname);
printf "Link has run with shim layer (?): %s\n", yesno($withshimlayer);



undef $dat;
$letti = read(FILE, $dat, 4) || die "Error reading";
if ( $letti < 4 ) { die "Premature end of file?! Maybe not a real LNK?"; }
$fileperm = unpack("L", $dat);
undef $dat;


gentarget("is read only", $fileperm & (0x01 << 0) );
gentarget("is hidden", $fileperm & (0x01 << 1) );
gentarget("is a system file", $fileperm & (0x01 << 2) );
gentarget("is a volume label", $fileperm & (0x01 << 3) );
gentarget("is a directory", $fileperm & (0x01 << 4) );
gentarget("has been modified since last backup", $fileperm & (0x01 << 5) );
gentarget("is encrypted", $fileperm & (0x01 << 6) );
gentarget("is normal", $fileperm & (0x01 << 7) );
gentarget("is temporary", $fileperm & (0x01 << 8) );
gentarget("is a sparse file", $fileperm & (0x01 << 9) );
gentarget("has reparse point data", $fileperm & (0x01 << 10) );
gentarget("is compressed", $fileperm & (0x01 << 11) );
gentarget("is offline", $fileperm & (0x01 << 12) );



$letti = read(FILE, $creationtimeL, 4) || die "Error reading";
$letti += read(FILE, $creationtimeH, 4) || die "Error reading";
$letti += read(FILE, $modificationtimeL, 4) || die "Error reading";
$letti += read(FILE, $modificationtimeH, 4) || die "Error reading";
$letti += read(FILE, $lastaccesstimeL, 4) || die "Error reading";
$letti += read(FILE, $lastaccesstimeH, 4) || die "Error reading";

if ( $letti < 24 )
{
  die "Failed reading dates into the LNK file! Corruption?";
}

# but I don't know the format!
$creationtimeL = unpack("L", $creationtimeL);
$modificationtimeL = unpack("L", $modificationtimeL);
$lastaccesstimeL = unpack("L", $lastaccesstimeL);
$creationtimeH = unpack("L", $creationtimeH);
$modificationtimeH = unpack("L", $modificationtimeH);
$lastaccesstimeH = unpack("L", $lastaccesstimeH);

# how a little endian arch read a quadword ?! i simply swapped lower/higher
# word (32bit)
printf "Creation time (uninterpreted quadword): %08X %08X\n", $creationtimeH, $creationtimeL;
printf "Modification time (uninterpreted quadword): %08X %08X\n", $modificationtimeH, $modificationtimeL;
printf "Last access time (uninterpreted quadword): %08X %08X\n", $lastaccesstimeH, $lastaccesstimeL;


$letti = read(FILE, $lun, 4) || die "Error reading";
if ( $letti  < 4 ) { die "Premature end of file? Corrupted or fake LNK?"; }
$lun = unpack("L", $lun);
printf "Target object length: %d\n", $lun;

$letti = read(FILE, $iconidx, 4) || die "Error reading";
if ( $letti < 4 ) { die "Premature end of file? Corrupted? ..."; }
$iconidx = unpack("L", $iconidx);
if ( $customicon ne 0)
{
  printf "Icon index: %08X\n", $iconidx;
}


$letti = read(FILE, $wind, 4) || die "Error reading";
if ( $letti < 4 ) { die "Cannot read ShowWnd value... corrupted LNK?"; }
$wind = unpack("L", $wind);
printf "ShowWnd value: %s\n", $showwnd[$wind];

$letti = read(FILE, $hotkey, 4) || die "Error reading";
if ( $letti < 4 ) { die "Cannot read HotKey ... corrupted LNK?"; }
$hotkey = unpack("L", $hotkey);
printf "Hotkey (as word integer?): %08X\n", $hotkey;

$letti = read(FILE, $dat, 8) || die "Error reading";
if ( $letti < 8 ) { die "Premature end of file?"; }
undef $dat;

if ( $shellitem ne 0 )
{
  print "\nSHELL ITEM ID LIST\n";
  $letti = read(FILE, $idtotlen, 2) || die "Error reading";
  if ( $letti < 2 ) { die "error in shell item id list"; }
  $idtotlen = unpack("S", $idtotlen);
  printf "Total length of the shell item id list (length inclusive): %d\n", $idtotlen;

  my $counta=0;
  LOOP: while ( 1 )
  {
     $letti = read(FILE, $seg, 2) || die "Error reading";
     if ( $letti < 2 ) { die "Error reading shell item... premature end"; }
     $seg = unpack("S", $seg);
     if ( $seg eq 0 ) { last LOOP; }
     printf "There's a item of length %d at offset 0x%X (length inclusive)\n",
            $seg, tell(FILE)-2;
     if ( $extract != "")
     {
       my $buf;
       $letti = read(FILE, $buf, $seg-2) || die "Error reading";
       if ( $letti < ($seg-2) )
       {
         die "Premature end of file. Corrupted?";
       }
       open(SALVA,">",$ARGV[0] . ".sii$counta") || die "Error saving a ShellItem";
       print SALVA $buf;
       close(SALVA);
       printf STDERR "ShellItem $counta saved to " . $ARGV[0] . ".sii$counta\n";
       $counta++;
     } else {
       seek(FILE, $seg-2, 1);
     }
     undef $seg;
  }

  # i lack more knowledge and resources to look inside these...
  print "SHELL ITEM ID LIST END\n\n";
}

# rev-eng doc says this is alway present, ... but it seems that if
# the points to file/dir flag is unset, this must be skipped
if ( $tofiledir ne 0 )
{
    $filelocinfo_offset = tell(FILE);
    $letti = read(FILE, $lenlink, 4) || die "Error reading";
    $lenlink = unpack("L", $lenlink);
    $letti = read(FILE, $nextoff, 4) || die "Error reading";
    $nextoff = unpack("L", $nextoff);
    if ( $tofiledir && ($lenlink ne 0))
    {

      if ( $nextoff ne 0x1c ) {
        print STDERR "Warning: file location info next offset out of my knowledge\n";
        print STDERR "I will try to cope with this anyway\n";
      }
      read(FILE, $fli_flags, 4) || die "Error reading";
      $fli_flags = unpack("L", $fli_flags);
      read(FILE, $fli_localvolume, 4) || die "Error reading";
      $fli_localvolume = unpack("L", $fli_localvolume);
      read(FILE, $fli_basepath, 4) || die "Error reading";
      $fli_basepath = unpack("L", $fli_basepath);
      read(FILE, $fli_networkvolume, 4) || die "Error reading";
      $fli_networkvolume = unpack("L", $fli_networkvolume);
      read(FILE, $fli_reminder, 4) || die "Error reading";
      $fli_reminder = unpack("L", $fli_reminder);

      $localtrue = 0;
      $networktrue = 0;
      if ( $fli_flags & 0x01 )
      {
        $localtrue = 1;
        print "Target is available on a local volume\n";
      }
      if ( $fli_flags & 0x02 )
      {
        $networktrue = 1;
        print "Target is available on a network share\n";
      }

    } elsif ( $letti < 4 ) {
      die "File Location Info error";
    } else {
      # skip bytes anyway according to len provided...
      # normally it is $nextoff = 0x1c
          #debug "Skipping $lenlink bytes?";
      $tofiledir = 0;
      if ( $lenlink ne 0 )
      {
        seek(FILE, $filelocinfo_offset+$lenlink, 0);
      } else {
        seek(FILE, $filelocinfo_offset+0x1c, 0);
      }
    }
}


if ( $tofiledir ne 0 )
{
  if ( $localtrue )
  {
    printf "\nOffset of local volume table: %08X\n", $fli_localvolume+$filelocinfo_offset;
    seek(FILE, $fli_localvolume+$filelocinfo_offset, 0);
    $lvi_len = get4(FILE);
    $lvi_type = get4(FILE);
    $lvi_serial = get4(FILE);
    $lvi_nameoffset = get4(FILE);
    if ( $lvi_nameoffset ne 0x10 )
    {
      printf STDERR "Volume Table has a strange volume name offset...\n";
    }
    printf "Volume type: %s\n", $voltype[$lvi_type];
    printf "Volume serial number: %08X\n", $lvi_serial;

    $volnamelen = $lvi_len - 4*4 - ($lvi_nameoffset - 0x10) -1;
    seek(FILE, $fli_localvolume+$filelocinfo_offset+$lvi_nameoffset, 0);
    $letti = read(FILE, $volumename, $volnamelen) || die "Error reading";
    if ( $letti < $volnamelen )
    {
      die "Something goes wrong reading volume name";
    }
    printf "Volume name: %s\n", $volumename;
    print "\n";
  }

  if ( $localtrue )
  {
    printf "Offset of base pathname on local system: %08X\n", $fli_basepath+$filelocinfo_offset;
    seek(FILE,$fli_basepath+$filelocinfo_offset,0);
    # how many bytes I have to read ?!
    read(FILE,$basename, 512) || die "Error reading";
    $stringa = unpack("Z*", $basename);
    printf "Base pathname: %s\n\n", $stringa;
    seek(FILE,$fli_basepath+$filelocinfo_offset+do { use bytes; length($stringa)} +1,0);
       # go to the real end... keep track because of the possible presence
       # of other string, like description and so on...
  }

  if ( $networktrue )
  {
    printf "Offset of network volument info: %08X\n", $fli_networkvolume+$filelocinfo_offset;
    seek(FILE,$fli_networkvolume+$filelocinfo_offset,0);
    $strulen = get4(FILE);
    get4(FILE);
    $nameoff = get4(FILE);
    if ( $nameoff ne 0x14 )
    {
      printf STDERR "Network Table has a strange offset of the network share name\n";
    }
    $netnamelen = $strulen - 5*4 - ($nameoff - 0x14);
    seek(FILE,$fli_networkvolume+$filelocinfo_offset+$nameoff,0);
    read(FILE, $netname, $netnamelen) || die "Error reading";
    printf "Network share name: %s\n\n", $netname;
  }

  printf "Offset of remaining path name: %08X\n", $fli_reminder+$filelocinfo_offset;
  seek(FILE,$fli_reminder+$filelocinfo_offset,0);
  read(FILE,$reminder,512) || die "Error reading";
  $stringa = unpack("Z*", $reminder);
  printf "Remaining path name: %s\n\n", $stringa;
  seek(FILE,$fli_reminder+$filelocinfo_offset+ do { use bytes; length($stringa) } +1,0);
}



if ( $description ne 0 )
{
  printf "Description: %s\n", getvstring(FILE);
}

if ( $relativepath ne 0)
{
  printf "Relative path: %s\n", getvstring(FILE);
}

if ( $workingdir ne 0)
{
  printf "Working dir: %s\n", getvstring(FILE);
}

if ( $commandline ne 0 )
{
  printf "Command line: %s\n", getvstring(FILE);
}

if ( $customicon ne 0 )
{
  printf "Custom icon: %s\n", getvstring(FILE);
}

# no more checks! all the info are out, so we don't care
read(FILE, $ex, 4) || die "Error reading";
$ex = unpack("L", $ex);
if ( $ex eq 0 )
{
  print "\nEND OF LNK\n\n";
  exit 0;
}
$act = tell(FILE);
printf "\nExtra stuff follows at offset 0x%X, length is %d\n\n", $act, $ex;

exit;

