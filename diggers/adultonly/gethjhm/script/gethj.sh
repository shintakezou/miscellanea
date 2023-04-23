#!/bin/bash
DDIR="hj"
URL="http://www.THE SITE.net"
useragent="Mozilla/5.0"
referer="$URL"
cook1="cook1"
cook2="cook2"

die()
{
  echo >&2 $@
  exit 1
}

download()
{
  if [ ! -e "$2" ]; then
    if [ -e "$cook1" ]; then
      curl -L -A $useragent -b $cook1 -c $cook2 -e $referer $1 -o $2 >/dev/null 2>/dev/null
      msg $?
      mv -f $cook2 $cook1
    else
      curl -L -A $useragent -c $cook1 -e $referer $1 -o $2 >/dev/null 2>/dev/null
      msg $?
    fi
  else
    echo -e "\033[32mexisting\033[0m"
  fi
}

rdownload()
{
  local imago
  local imm
  local mimm
  local succ
  local isuc
  local nbase

 nbase=`dirname $1`
 echo -n "downloading $1 ..."
 download $1 $2

 # template of the URL: /foto/xxxxxx.jpg
 imago=`cat $2 |ginlineimg |sort |uniq |egrep /foto/.*\.jpg$`
 for imm in $imago
 do
   mimm=`basename $imm`
   echo -ne "\033[1mimage\033[0m $imm ..."
   download $imm $DDIR/$mimm
 done

  # Aventi = forward (next), this is the link to the next page
 succ=`cat $2 |egrep 'Avanti[^<]*</a>' |getaddrs`
 if [ "$succ" = "" ]; then
   return
 fi
 for isuc in $succ
 do
   if [ `echo $isuc |egrep -c ^http://` -ne 0 ]; then
     return
   fi
   rdownload $nbase/$isuc $DDIR/$isuc
 done

}

msg()
{
  if [ $1 -ne 0 ]; then
    echo -e "\033[31merror\033[0m"
    exit 1
  else
    echo -e "\033[32mdone\033[0m"
  fi
}

if [ ! -d "$DDIR" ]; then
  mkdir $DDIR || die "Err. creating $DDIR"
fi

echo -n "downloading $URL/menu.html ..."
download $URL/menu.html $DDIR/menu.html

for lurl in `cat $DDIR/menu.html | egrep "$1" |getaddrs |sort |uniq |egrep /gallerie001/[^/]*_[0-9]\+_[0-9]\+\.html?$`
do
  bdest=`basename "$lurl"`
  rdownload $lurl $DDIR/$bdest
done

echo -e "\033[32mall done\033[0m"

exit 0
