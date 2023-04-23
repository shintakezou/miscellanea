#!/bin/bash
. filenames

TEMP=`mktemp tmp.XXXXXX`

if [ $# -lt 1 ]
then
  echo "Usage: select.sh NUMBER"
  exit 1
fi

LINES=$( cat $STUFFILE |grep -v ^$ |grep -c $ )
RESTO=$(( $LINES - $1 ))

echo "Extracting $1 lines from $STUFFILE ..."
cat $STUFFILE |grep -v ^$ |head -n $1  > $TEMP
cat $STUFFILE |grep -v ^$ |tail -n $RESTO >> $THELIST
mv -f $TEMP $STUFFILE

echo "Re-sorting $THELIST ..."
cat $THELIST |sort |uniq > $TEMP
mv -f $TEMP $THELIST

echo "Done."
