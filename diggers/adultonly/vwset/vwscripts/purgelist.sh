#!/bin/bash
#purgelist.sh
. filenames

TEMP=`mktemp tmp.XXXXXXXXX`
TEMP2=`mktemp tmp.XXXXXXXXX`

echo "Purifying $THELIST ..."

cat $DOWNFILE $TABU > $TEMP2
grep -v -f $TEMP2 $THELIST > $TEMP
rm $TEMP2
mv -f $TEMP $THELIST
echo "Done."
