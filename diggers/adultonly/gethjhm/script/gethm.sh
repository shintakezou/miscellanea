#!/bin/bash
DDIR="hm"
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
  local fimago
  local succ
  local isuc
  local nbas

  nbas=`dirname $1`
  echo -n "downloading $1 ..."
  download $1 $2

  imago=`cat $2 |ginlineimg |sort|uniq |egrep A\&A_.*\.jpg$`
  fimago=`basename $imago`

  echo -ne "\033[1mimage $imago\033[0m ..."
  download $URL/$imago $DDIR/$fimago

  succ=`cat $2 |egrep 'Next[^<]*</a>' |getaddrs |sort |uniq`
  if [ "$succ" = "" ]; then
    return
  fi
  for isuc in $succ
  do
    rdownload $nbas/$isuc $DDIR/$isuc
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

echo -n "downloading $URL/foto.html ..."
download $URL/foto.html $DDIR/foto.html

for lurl in `cat $DDIR/foto.html |getaddrs |sort |uniq |egrep ^A\&A_[0-9]\+_01\.html?`
do
  bdest=`basename $lurl`
  rdownload $URL/$lurl $DDIR/$bdest
done

echo -e "\033[32mall done\033[0m"

exit 0
