#!/bin/bash
kamadir="kamasutra"
kamaurl="http://www.alfemminile.com"
ajar="kamacook1"
bjar="kamacook2"
errlog="kamasutra.log"
# paddr="couple/newlovemach/touteslespositions.asp?i=1&pcourante=1"
postemplate="/couple/newlovemach/afficheposition.asp?numero="
kaman=50

sayerror()
{
  echo -e "\033[31merror\033[0m"
}

sayok()
{
  echo -e "\033[32mdone\033[0m"
}

existing()
{
  echo -e "\033[32mexisting\033[0m"
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

echo -n "create $kamadir ..."
if [ ! -e $kamadir ]; then
  mkdir $kamadir || ( sayerror; exit 1 ) 
  sayok
else
  existing
fi

#v1 con wget
cd $kamadir
for numi in `seq $kaman -1 1`
do
  echo -n "download position $numi ..."
  wget -E -H -k -K -p $kamaurl$postemplate$numi --save-cookies $ajar -U Mozilla/5.0 --quiet -o $errlog
  if [ $? -eq 0 ]; then
    sayok
  else
    sayerror
    exit 1
  fi
  sleep 1
done

exit 0