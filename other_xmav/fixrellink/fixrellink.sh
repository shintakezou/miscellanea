#! /bin/bash
# fixrellink.sh - fix relative links
# Copyright (C) 2008 Mauro Panigada
#
# --- add GPLv2 full text ---

# The problem:
#    let us suppose you created into /usr a link to /mnt/ext/usr/real_share with
#    the name share. Since /mnt/ext is mounted on another hd (e.g. second IDE) or
#    another partition, the aim is to make more room on the / mount point.
#    Everything goes fine until you meet two problems:
#       * relative links that "go out" from, or better "go upper" than
#         the /usr/share, since e.g. [/usr/share/].. goes to /mnt/ext/usr
#         instead of /usr
#       * you do a "ls .." inside the /usr/share. What you list is again
#         the content of /mnt/ext/usr dir and NOT the /usr dir!
#
# Solution:
#    I have no solution for the second *. Even though you do a
#    "ls /usr/share/.." you get the list of /mnt/ext/usr dir: the ".." do not
#    walk the absolute path but seems to resolve and follow links, so once
#    you get into /mnt/ext/usr/real_share with the "/usr/share" part, the
#    parent is "/mnt/ext/usr", alas.
#
#    For the first point, a solution could be to make absolute path links
#    for those links that "go out" the /usr/share/ domain. This could not
#    fix the problem, so a roll-back mechanism must be provided.
#
#    Original links are stored (real path, linked path)
#    into a file. This is the roll-back mechanism. You can use the rollback
#    file to create the original links. Creation date of the link is not
#    preserved.
#
# Usage:
#    fixrellink.sh path/where/must-be-fixed-links/appear real/base/dir rollback-file
#
#    E.g.:
#       fixrellink.sh /mnt/ext/usr/ext_share /usr rollback.txt
#
#       this works when you have the following situation:
#                /usr/share  ->  /mnt/ext/usr/ext_share
#
#    USE ABSOLUTE PATH (you can use safely relative paths for the first arg,
#          but for the secondo you must provide absolute path, and it's
#          natural if you think about it!)
#
# How it works (or not!):
#    Find all links from /mnt/ext/usr/ext_share downstream. For each
#    link, check if it is relative. If it is relative, walk it and see
#    if it goes out from /mnt/ext/usr/ext_share, even once! (e.g.
#    /usr/share/../share does not list /usr/share as expected but
#    /mnt/ext/usr/share!). If it goes outside, walk relatively to
#    /usr/share, find the absolute path e create the new link.
#    Before doing so, move the old link to _originallink and save the
#    info into the rollback-file.

die()
{
   echo "$*" >&2
   exit 1
}

okmsg()
{
   if [[ -z "$*" ]]; then
     echo -e "\e[32mok\e[0m"
   else
     echo -e "\e[32m$*\e[0m"
   fi
}

nomsg()
{
   if [[ -z "$*" ]]; then
     echo -e "\e[31mno\e[0m"
   else
     echo -e "\e[31m$*\e[0m"
   fi
}

warn()
{
   echo -e "\e[31mWARNING:\e[0m $*" >&2
}


checkpath()
{
    local sd rp lp bd act
    sd="$1"            # reference scan dir
    rp="$(dirname "$2")"            # real path of the link
    act="$rp"           # actual dir
    lp="$3"            # the link linked path
    # bd="$4"            # base dir to fix it
    IFS="/"
    sd=$(echo "$sd" |sed -e 's|/\+$||g')
    for l in $lp; do
       if [[ "$l" == ".." ]]; then
          if [[ "$act" == "$sd" ]]; then
             echo 1
             return
          fi
          act=$(dirname "$act")
       else
          act="$act/$l"
       fi
    done
    echo 0
}

#
# createpath LINKPATH LINKEDRELATIVE BASE RBASE
# e.g. createpath /mnt/ext/usr/ext_share/mini/lib/sol.so ../../../lib/sol0.so /usr/share
#                                    [ /mnt/ext/usr/ext_share
# gives: /usr/lib/sol0.so
createpath()
{
    local lp rp bd sp act
    lp="$(dirname "$1")"                # linkpath
    rp="$2"                # relative path
    bd="$3"                # basedir
    sp="$4"                # "real" base
    asp="$(dirname "$sp")"
    act=$(echo "$lp" |sed -e "s|^$asp|$bd|")
    # now must absolutise act according to rp
    IFS="/"
    for l in $rp; do
        if [[ "$l" == ".." ]]; then
            if [[ "$act" == "/" ]]; then
               warn "trying to get up from root /"
               continue
            fi
            act=$(dirname "$act")
        elif [[ "$l" == "." ]]; then
            continue
        else
            if [[ "$act" != "/" ]]; then
              act="$act/$l"
            else
              act="/$l"
            fi
        fi
    done
    echo -n "$act"
}


#======================================================== MAIN

# ---- ROLLBACK mechanism
if [[ "$1" == "--rollback" ]]; then
   if [[ -z "$2" ]]; then
      die "specify a rollback file"
   fi
   if [[ ! -f "$2" ]]; then
      die "rollback must be an existing file"
   fi
#   rolf=0
   while read linea; do
        if [[ -z "$linea" ]]; then continue; fi
#         if [[ "$linea" == "fixrellink.sh rollback file" ]] && [[ $rolf -eq 0 ]] ; then
#            rolf=1
#            continue
#         fi
#         if [[ $rolf -eq 1 ]]; then
#           read data
#           rolf=2
#           continue
#         fi
        fullpath=$(echo "$linea"|awk -F ' ::: ' '{print $1}')
        original=$(echo "$linea"|awk -F ' ::: ' '{print $3}')
        echo -n "Checking if you can rollback \"$fullpath\"... "
        if [[ -w "$(dirname "$fullpath")" ]]; then
            okmsg "you can"
        else
            nomsg "no!"
            continue
        fi

        echo -n "Rolling back \"$fullpath\"... "
        if [[ -h "$fullpath" ]]; then
          rm "$fullpath" &>/dev/null
          if [[ $? -ne 0 ]]; then
              nomsg "failed"
              continue
          fi
          ln -s "$original" "$fullpath" &>/dev/null
          if [[ $? -ne 0 ]]; then
              nomsg "failed"
              continue
          fi
          okmsg
        else
          warn "\"$fullpath\" is not a symbolic link; ignoring"
        fi
   done <"$2"
#    if [[ $rolf -eq 0 ]]; then
#        die "is \"$2\" a rollback file?!"
#    fi
   exit 0
fi

if [[ $# -lt 3 ]]; then
   die "required arguments missing"
fi

if [[ -e "$3" ]]; then
   die "roll back target \"$3\" exists"
fi

if [[ "${2:0:1}" != "/" ]]; then
  die "base dir MUST be an absolute path starting with /"
fi

if [[ ! -d "$1" ]]; then
   die "\"$1\" must be an existing directory"
fi

scandir="$1"
basedir="$2"
rollfile="$3"

#------------------------------------------------------------
echo -n "Checking if you are root... "
if [[ $UID -gt 0 ]]; then
   nomsg "no"
else
   okmsg "yes"
fi

#----------------------------------------------------------
echo -n "Checking the owner of \"$scandir\"... "
if [[ -O "$scandir" ]]; then
   okmsg "you"
else
   nomsg "not you"
   warn "you are not the owner of \"$scandir\": problems can arise!"
fi

#-------------------------------------------------------
echo -n "Checking if \"$rollfile\" is writable... "
rolldir=$(dirname "$rollfile")
if [[ -w "$rolldir" ]]; then
    okmsg
    #echo "fixrellink.sh rollback file" >"$rollfile"
    #echo `date +%Y%m%d-%H%M%S` >>"$rollfile"
else
    nomsg
    die "cannot write into \"$rolldir\""
fi

#------------------------------------------------------
echo -n "Scanning \"$scandir\" for links... "
listl=$(find "$scandir" -type l -printf "%p ::: %l\n" 2>/dev/null |egrep "\.\." 2>/dev/null)
okmsg "done"

#---------------------------------------------------------
echo -n "Counting interesting links... "
IFS="
"
lnum=$(echo "$listl" |wc -l)
okmsg "$lnum"

#--------------------------------------------------------
nn=0
fixtask=""
fn=0
for lnk in $listl; do
  if [[ -z "$lnk" ]]; then continue; fi
  (( perc = 100*nn / lnum ))
  printf "Checking for to-be-fixed... %3d%%\r" $perc
  realpath=$(echo "$lnk"|awk -F ' ::: ' '{print $1}')
  linkpath=$(echo "$lnk"|awk -F ' ::: ' '{print $2}')
  if [[ $(checkpath "$scandir" "$realpath" "$linkpath" ) -ne 0 ]]; then
     fact="$realpath ::: $(createpath "$realpath" "$linkpath" "$basedir" "$scandir" ) ::: $linkpath"
     fixtask="$fixtask$fact
"
     (( fn++ ))
  fi
  (( nn++ ))
done
printf "Checking for to-be-fixed... 100%%\n" $perc

echo -n "How many links need to be fixed... "
okmsg "$fn"

echo -n "Updating rollback... "
echo "$fixtask" >>"$rollfile"
okmsg

IFS="
"

for lnk in $fixtask; do
   if [[ -z "$lnk" ]]; then continue; fi
   realpath=$(echo "$lnk"|awk -F ' ::: ' '{print $1}')
   newlinke=$(echo "$lnk"|awk -F ' ::: ' '{print $2}')
   echo -n "Fixing \"$realpath\"... "
   rm "$realpath" >/dev/null 2>/dev/null
   if [[ $? -ne 0 ]]; then
      nomsg "failed"
      continue
   fi
   ln -s "$newlinke" "$realpath" >/dev/null 2>/dev/null
   if [[ $? -ne 0 ]]; then
      nomsg "failed"
      continue
   fi
   okmsg "fixed"
done

exit 0
