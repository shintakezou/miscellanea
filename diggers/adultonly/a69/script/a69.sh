#!/bin/bash
#arguments: id, name
# e.g.
# a69.sh 25375 Ver26
url="http://www.THE SITE.it"
# php script parsing our request, with id= ...
palco="/palco.php?id="
# another arg for the php script
directory="&directory=annunci/TYPE/"
# select the current pic
picc="&currentPic="
#1
# FORGED URL example
#http://www.THE SITE.it/palco.php?id=25375&directory=annunci/TYPE/Ver26&currentPic=1
cl="curl -A Mozilla/5.0"
ajar="cj1"
bjar="cj2"
errlog="a69.log"
gn=1

sayerror()
{
  echo -e "\033[31merror\033[0m"
}

sayok()
{
  echo -e "\033[32mdone\033[0m"
}

rfile()
{
  if [ -e $ajar ]; then
    $cl -b $ajar -c $bjar "$1" -o $2 >/dev/null 2>$errlog
    err=$?
    mv -f $bjar $ajar 2>/dev/null >/dev/null
  else
    $cl -c $ajar "$1" -o $2 >/dev/null 2>$errlog
    err=$?
  fi
  if [ $err -ne 0 ]; then
    sayerror
    exit 1
  else
    sayok
  fi
}

tfile()
{
  local img
  local rname
  local nusu

  for img in `cat $1 |ginlineimg |egrep /$2/.*\.[jJ][pP][gG]`
  do
    rname="`basename $img`"
    if [ -e $ddir/$rname ]; then
      echo "existing $ddir/$rname"
    else
      echo -n "download image $url/$img ..."
      rfile $url/$img $ddir/$rname
    fi
  done

  # Avanti = Next = Forward
  succ="`cat $1|egrep -A 1 Avanti |getaddrs`"
  if [ "$succ" == "" ]; then
    return
  fi
  gn=$(( $gn + 1 ))
  nusu=`echo "$succ" |sed -e 's/^.*currentPic=\([0-9]\+\)/\1/'`
  if [ $nusu -lt $gn ]; then
    echo "END"
    exit 0
  fi
  echo -n "download $url$succ to $ddir/ph$gn.html ..."
  rfile $url$succ $ddir/ph$gn.html
  echo "enter level $gn"
  tfile $ddir/ph$gn.html $2
}

ddir="$1$2"
if [ ! -e $ddir ]; then
  mkdir $ddir || exit 1
fi

echo -n "download $url$palco$1$directory$2${picc}1 to $ddir/ph1.html ..."
rfile "$url$palco$1$directory$2${picc}$gn" $ddir/ph$gn.html
echo "enter level $gn"
tfile $ddir/ph$gn.html $2

exit 0
