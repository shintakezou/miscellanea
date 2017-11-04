#!/bin/bash
# get ca all (of a region)
baseurl="http://www.THE SITE/"
scook="cookbook"
lcook="cookbook2"
ddir="store"
dnc=0
slet=3
rlet=$slet
seed=1457378
purl='curl -A Mozilla/5.0 -s -S'

function msg {
  if [ $1 -eq 0 ]; then
    echo $2
  else
    echo "error $1"
    cat $err
    rm $err
    exit 1
  fi
}

function slop {
    sleep $(($slet+$1))
}

if [ ! -d $ddir ]; then
  mkdir $ddir || exit 1
fi

if [ $# -lt 1 ]; then
  echo "Specify one or more regions"
  exit 1
fi

if [ $# -eq 2 ] && [ "$1" == "-l" ]; then
  cat "$2" |getaddrs |grep "^fa_menu" |sed -e 's/fa_menu.*regione=//'
  exit 0
fi

if [ ! -d pic ]; then
  mkdir pic
  echo "Directory 'pic' created"
fi

err=`mktemp err.XXXX`

echo -n "Trying to get cookies ..."
$purl -c $scook $baseurl >/dev/null 2>$err
msg $? "done"

for regioni in $*
do
  echo -n "Getting list of the region $regioni ..."
  $purl -b $scook -c $lcook ${baseurl}fa/fa_menu.asp?regione=$regioni -o $ddir/reg$regioni.html >/dev/null 2>$err
  msg $? "done"
  mv -f $lcook $scook
  for annuncio in `cat $ddir/reg$regioni.html |getaddrs |egrep ^show_annuncio`
  do
    annid=$( echo $annuncio |sed -e 's/^show_annuncio\.asp.id=//')
    echo -n "Downloading ad. id $annid ..."
    if [ -e $annid.html ]; then
      continue
    fi
    $purl -b $scook -c $lcook ${baseurl}fa/$annuncio -o $annid.html >/dev/null 2>$err
    msg $? "done"
    mv -f $lcook $scook
    for imago in `cat $annid.html |ginlineimg |egrep "[0-9]*/[0-9]*_?[0-9]*\.jpg$"`
    do
      nimago=$( echo $imago |sed -e 's|/|_|g')
      echo -n "Downloading picture $imago ..."
      $purl -b $scook -c $lcook ${baseurl}fa/$imago -o pic/id$annid-$nimago >/dev/null 2>$err
      msg $? "done"
      dnc=$(($dnc+1))
      mv -f $lcook $scook
    done
    slop 0
  done
  slop 1
done
echo "End; downloaded $dnc images"
exit 0
