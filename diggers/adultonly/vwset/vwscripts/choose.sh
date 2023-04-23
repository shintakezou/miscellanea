#!/bin/bash
. filenames

ACTION=list
DTYPE=novoy
RETYPE="-v ^http://voy."
DNUMBER=10

if [ $# -lt 1 ]; then
  echo "Usage: choose.sh list|stuff [type=TYPE] [number=NUMBER]"
  echo
  echo "TYPE can be: vw"
  echo "             ps"
  echo "             voy"
  echo "             novoy (default)"
  echo
  exit 1
fi


for argu in "$@"
do
  case $argu in
    list)
      ACTION=list
      ;;
    stuff)
      ACTION=stuff
      ;;
    type=*)
      DTYPE=$( echo $argu |sed -e 's/type=//' )
      ;;
    number=*)
      DNUMBER=$( echo $argu |sed -e 's/number=//' )
      ;;
    *)
      echo "Invalid option or argument $argu"
      exit 1
      ;;
  esac
done

case $DTYPE in
novoy)
 ;;
voy)
  RETYPE="^http://voy."
  ;;
vw)
  RETYPE="^http://ww3.voyeurweb"
  ;;
ps)
  RETYPE="^http://www.privateshots"
  ;;
*)
  echo "Invalid type $DTYPE, supposing 'novoy' instead."
  ;;
esac

case $ACTION in
list)
  grep $RETYPE $THELIST | head -n $DNUMBER >> $STUFFILE
  uniquecheck.sh
  exit 0
;;
stuff)
  TMP=`mktemp tmp.XXXXXXXX`
  grep $RETYPE $STUFFILE | head -n $DNUMBER > $TMP
  grep -v -f $TMP $STUFFILE >> $THELIST
  mv -f $TMP $STUFFILE
  sort $THELIST |uniq > $TMP
  mv -f $TMP $THELIST
  exit 0
;;
esac
