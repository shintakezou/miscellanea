#!/usr/bin/perl -w

# $Author: Mauro Panigada $
# $Version: 1.1 $
# $Distributed under: GPL $
#
# last update: 20070212
# known BUGS: unprotected filename using,
#             MS Windows intolerant
#
# needs a *n*x - GNU/Linux environment (uses rm, basename etc.)

# USAGE:
# linkall.pl PATH

use HTML::Parser();

my %aattr;
my %imgattr;

$dirsepchar = "/";

if ( ! @ARGV > 0) {
  print "usage error\n";
  exit 1;
}

my @rlist;
my %htmllist;
my %resourcelist;
my $bd;

sub collectel {

  my $dd = shift(@_);
  my @el = @_;
  foreach (@el)
  {
    if ( -f "$dd$dirsepchar$_" ) {
      if ( "$_" =~ /\.html?$/ ) {
        $htmllist{$_} = "$dd$dirsepchar$_";
        #push @htmllist,"$dd$dirsepchar$_";
      } else {
        $resourcelist{$_} = "$dd$dirsepchar$_";
        #push @resourcelist,"$dd$dirsepchar$_";
      }
    }
    if ( -d "$dd$dirsepchar$_"  ) {
      opendir(IDIR,"$dd$dirsepchar$_") || return;
      my @plist;
      @plist = grep { !/^\./ } readdir(IDIR);
      collectel("$dd$dirsepchar$_",@plist);
      closedir(IDIR);
    }
  }

}

$bd = $ARGV[0];
$bd =~ s/\/$//;  # removes trailing / FIXME on Windows system it must be \

-d "$bd" || die "$bd is not a dir";


opendir(MDIR,$bd) || die "cannot open $bd: $!";
@rlist = grep { !/^\./ } readdir(MDIR);
collectel($bd,@rlist);
closedir(MDIR);

# now @htmllist contains all file .htm and .html, maybe real
# html files... no more checks are done.
# and @resourcelist contains all other kinds of files.
#
# now for each @htmllist
#   for each link or img in this html
#     if the last part of the url matches any resource or html
#       modify the link so that it points to that resource or html
#     else
#       keep the link/img unchanged
#
# when all the job is done, all html files are browseable and links to their
# images or htmls correctly, so that you can see images and follow a link!
#
# TODO: better search using hashes? now for each link all the array is scanned,
#       sequentially and this is not so smart, indeed it's time consuming.
#       DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE DONE
#
# FIXME: I am going to use tools I am sure are on *n*x systems but I can't say
#        for Windows, so portability is maybe broken, but it ought to be all right
#        if you write down or have these tools: basename, dirname
# FIXME: portability issue again: you have to fix by hands if you are on a Windows
#        system the slash -> it should be a backslash instead. Find out other fix
#        points where I hardcoded the slash :-), and change $dirsepchar into \

sub findrelpath {
  my ( $hh, $d ) = @_;
  # here we have to find HOW to reach $d, the destination resource,
  # starting from $h.
  # 3 cases:
  # 1) $d is in $h, this means that "dirname" on $d gives $h
  # 2) $d is in a subdir of $h; i.e.  $h is a substring of $d,
  #    starting from the beginning
  # 3) $d is a parent; $d is a substring of $h
  #
  # solutions:
  # 1) basename of $d is enough
  # 2) the substring $h must be stripped from $d
  # 3) the substring $d must be stripped from $h and the number of dir
  #    left becomes "..", for example 2 becomes "../../" and so on.

  # CASE 1 -- resource point the same place of the document
  my $pd = `dirname "$d"`;
  chomp($pd);
  chomp($hh);
  #print "DBG $pd " . $hh ."\n";
  if ( "$pd" eq "$hh" ) {
    my $ct = `basename "$d"`;
    chomp($ct);
    return "$ct";
  }

  # CASE 2 -- the ref points to something inside a dir that is in the
  #           same place of the document
  if ( "$pd" =~ m|^$hh\/?(.*)| ) {   # FIXME: on Windows, \/ is \\
    #chomp($1);
    #print "DBG-a $1\n";
    if ( "$1" ne "" ) {
      my $fp = `basename "$d"`;
      chomp($fp);
      return "$1$dirsepchar$fp";
    }
  }

  # CASE 3 -- the ref points to something outside the place where
  #           the document is
  if ( "$hh" =~ m|^$pd\/?(.*)| ) {  # FIXME: on Windows, \/ is \\
    #chomp($1);
    #print "DBG-b $1\n";
    if ( "$1" ne "" ) {
      my $spitto = $1;
      # $spitto =~ s/^\.\///;  # destroy heading ./ if any; FIXME on Windows...
      my @dslist = split(/$dirsepchar/,"$spitto");
      my $uplev = @dslist;
      my $ul = "";
      while ( --$uplev >= 0 )     # CHECK!!
      {
        $ul = $ul . "..$dirsepchar";
      }
      my $fp = `basename "$d"`;
      chomp($fp);
      return "$ul$fp";
    }
  }

  # CASE XXX :-D
  my $ct = `basename "$d"`;
  chomp($ct);
  $hh =~ s/^\.\///;        # FIXME for Wndows...
  my @dslist = split(/$dirsepchar/,"$hh");
  my $uplev = @dslist;
  my $ul = "";

      while ( --$uplev >= 0 )
      {
        $ul = $ul . "..$dirsepchar";
      }

    $pd =~ s/^\.\///;
      # FIXME: Windows, \/ -> \\
    return "$ul$pd$dirsepchar$ct";
}


#code for parsing html
sub tag {
  my ( $tagname, $fattr, $txt, $fn ) = @_;

  if ( !defined($fattr) ) {
       open (FT, ">>$fn") || return;
       print FT "$txt";
       close(FT);
       return;
  }
  my %attr = %$fattr;

  # TODO it should be added the style tag, handling @import directive of CSS
  # reparsing it as url, so that everything goes fine
  if ( ($tagname eq 'a') or ($tagname eq 'area') or ($tagname eq 'link') ) {     #--------------------- A, AREA, LINK HREF

    if ( !defined($attr{href}) ) {
        open (FT, ">>$fn") || return;
        print FT "$txt";
        close(FT);
        return;
    } else {
      # we have to modify this url, IFF basename is not an anchor (i.e.
      # does not contain # for the same doc) and exists a file with such a name in our
      # resource/html list.
      my $tpn = $attr{href};
      my $thehash = "";
      if ( "$tpn" =~ /\#/ ) {
        # a hash is present; let's see if is within this document or
        # outside; in the latter we must preserve hash, do the same job
        # as if there were nothing, then append the hash.
        if ( "$tpn" =~ /^\#/ ) {
          # hash at the beginning, reference untouched
           open (FT, ">>$fn") || return;
           print FT "$txt";
           close(FT);
           return;
        } else {
          # there's a hash but not inside, it seems
          #my $nohash = $tpn;
          #$nohash =~ s/\#(.*)$//;
          $tpn =~ s/(\#.*)$//;      # href without hash
          $thehash = "$1";
          chomp($thehash); # hmmm not a need
            # go on as if nothing's happened...
        }
      }

      # FIXME this a very drastical strip: erase all from ? to the end...
      # because it sounds like a "message" or paramenter in a URL...
      # 20070212
      if ( $tpn =~ /\?/ )
      {
        $tpn =~ s/\?.*$//;
      }

      my $bname = `basename "$tpn"`;
      chomp($bname);

      if ( !defined( $resourcelist{$bname} ) && !defined( $htmllist{$bname} ) )
      {
            open(FT,">>$fn") || return;
            print FT "$txt";
            close(FT);
            return;
      }

      # hmm it is defined, or in resourcelist or in htmllist.
      # no matter which, but we need indeed to know...
      my %realref;
      if ( defined( $htmllist{$bname} ) )
      {
        %realref = %htmllist;
      } else {
        %realref = %resourcelist;
      }

      my $herepath = `dirname "$fn"`;
      chomp($herepath);
      my $relpa = findrelpath("$herepath", $realref{$bname});

      #print STDERR "$herepath " . $realref{$bname} . " $relpa\n";

      open(FT,">>$fn") || return;
        # change the style so you can identify this link, I suppose
        # but do not do it for link ! 20070212
      if ( $tagname ne 'link' )
      {
        print FT "<$tagname style=\"font-weight: bold; background-color: yellow;\" ";
      } else {
        print FT "<$tagname ";
      }

      foreach my $kiave ( keys %attr ) {
        if ( ($kiave ne "href") ) {
          if ( ($kiave ne "/" )) {   # it seems XHTML confund the html parser...
                                     # this should avoid interpreting / of a
                                     # "singlet" tag as an attribute
            print FT "$kiave=\"" . $attr{$kiave} . "\" ";
          }
        } else {
          print FT "href=\"" . $relpa . $thehash . "\" ";
        }
      }

      print FT ">";
      close(FT);

    }

  } elsif ( $tagname eq 'img' ) {   #------------------------- IMAGE

      if ( !defined($attr{src}) ) {
          open (FT, ">>$fn") || return;
          print FT "$txt";
          close(FT);
          return;
      } else {
        # the src cannot contains any # so here we only have to check out for
        # existing images... - resources only
        my $tpn = $attr{src};
        my $bname = `basename "$tpn"`;
        chomp($bname);

        if ( !defined ( $resourcelist{$bname} ) ) {
            open(FT,">>$fn") || return;
            print FT "$txt";
            close(FT);
            return;
        } else {
          my $herepath = `dirname "$fn"`;
          chomp($herepath); # done after anyway... redundant?
          #print "DBG1 $herepath";
          my $relpa = findrelpath("$herepath", $resourcelist{$bname});
          print STDERR "$herepath " . $resourcelist{$bname} . " $relpa\n";
          open(FT,">>$fn") || return;
          print FT "<img ";
          foreach my $kiave ( keys %attr ) {
              if ( $kiave ne "src" ) {
                print FT "$kiave=\"" . $attr{$kiave} . "\" ";
                # indeed this modify maybe the aspect of each attr... but
                # all still has to work fine.
              } else {
                print FT "src=\"" . $relpa . "\" ";
              }
          }
          print FT ">";
          close(FT);
        }
      }
  } else {                          #----------------- no IMG no A HREF
      open (FT, ">>$fn") || return;
      print FT "$txt";
      close(FT);
      return;
  }
}

sub deftext {
  my ($txt, $fn) = @_;
  open (FT, ">>$fn") || return;
  print FT "$txt";
  close(FT);
}

# now i have to read in each .html? file and pass it through the parser.
# the parser will output the code with href and src addresses "correct".

my $tempfn;

foreach( keys %htmllist )
{
  my $tname = $htmllist{$_};
  print "parsing " . $tname . "\n";
  $tempfn = "$tname" . ".tmp";

  if ( -f "$tempfn" ) {
    `rm "$tempfn"`;
  }

  my $pob = HTML::Parser->new(api_version => 3,
                  handlers => [
                                default => [ \&deftext, "text, '$tempfn'" ],
                                start   => [ \&tag, "tagname, attr, text, '$tempfn'" ]
                              ],
                  marked_sections => 1
                 );

  $pob->utf8_mode; # shoore?!
  $pob->parse_file("$tname") || die "parserror: $!\n";
  $pob->eof();

  # well well we are the champions!
  # now let's rename that stuff with the best name for it
  # .html? -> .bk
  # .tmp -> stripppppp

  my $bkname = $tname;
  $bkname =~ s/\.html?$/.bk/;
    # FIXME: ooh yet *n*x, *n*x rules; fix your windows system: remove that
    # dangerous virus... or fix here with what you need on your system for
    # renaming a file... Perl can do it, but historically I didn't know
    # about rename!
  `mv "$tname" "$bkname"`;
  `mv "$tname.tmp" "$tname"`;

}



exit
