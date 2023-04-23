#!/bin/bash
. filenames

LOGFILE=uniquelog.log
TEMP=`mktemp tmp.XXXXXX`
TMP1=`mktemp tmp.XXXXXX`
CNT=0

if [ -e $LOGFILE ]
then
  rm $LOGFILE
fi

cat $DOWNFILE $TABU > $TMP1
grep -v -f $TMP1 $STUFFILE > $TEMP
CNT=`grep -c -f $TMP1 $STUFFILE`
grep -f $TMP1 $STUFFILE > $LOGFILE

sort $TEMP |uniq > $STUFFILE
rm $TEMP
rm $TMP1
echo "Found $CNT non unique links logged into $LOGFILE"
exit 0
