#!/bin/bash

# creates a calendar

# calendar.sh [YEAR] [FIRST MONTH] [LAST MONTH]
#

mesi="JAN FEB MAR APR MAY JUN JUL AGO SEP OCT NOV DIC"
#        31      28     31    30      31     30     31      31    30        31       30       31

if [ "$2" == "" ]; then
  meseinizio=1
else
  meseinizio=$2
fi

if [ "$3" == "" ]; then
  mesefine=12
else
  mesefine=$3
fi

if [ $meseinizio -gt $mesefine ]; then
  app=$mesefine
  mesefine=$meseinizio
  meseinizio=$app
fi

if [ "$1" == "" ]; then
  anno=`date +%Y`
else
  anno=$1
fi

echo "Creating calendar year $anno, months from $meseinizio to $mesefine" >&2

echo "<html><head><title>Calendar $anno</title></head><body>"
echo "<table border=1><tr>"

for mensi in `seq $meseinizio $mesefine`
do
  echo "<td valign=top><table>"
  dom=`cal $mensi $anno |awk 'BEGIN {FIELDWIDTHS="3 3 3 3 3 3 3"} !/[a-z]/ {print "\042" $1 "\042"}'`
  lun=`cal $mensi $anno |awk 'BEGIN {FIELDWIDTHS="3 3 3 3 3 3 3"} !/[a-z]/ {print "\042" $2 "\042"}'`
  mar=`cal $mensi $anno |awk 'BEGIN {FIELDWIDTHS="3 3 3 3 3 3 3"} !/[a-z]/ {print "\042" $3 "\042"}'`
  mer=`cal $mensi $anno |awk 'BEGIN {FIELDWIDTHS="3 3 3 3 3 3 3"} !/[a-z]/ {print "\042" $4 "\042"}'`
  gio=`cal $mensi $anno |awk 'BEGIN {FIELDWIDTHS="3 3 3 3 3 3 3"} !/[a-z]/ {print "\042" $5 "\042"}'`
  ven=`cal $mensi $anno |awk 'BEGIN {FIELDWIDTHS="3 3 3 3 3 3 3"} !/[a-z]/ {print "\042" $6 "\042"}'`
  sab=`cal $mensi $anno |awk 'BEGIN {FIELDWIDTHS="3 3 3 3 3 3 3"} !/[a-z]/ {print "\042" $7 "\042"}'`
  echo "$mesi" | awk "{ print \"<tr><td align=center bgcolor=#AAEEFF colspan=2><b>\" \$$mensi \"<b></tr></td>\" }"
  for((i=1;i<=31;i++))
  do
      if [ `echo "$dom" |grep -w -c $i` -ne 0 ]; then
        echo "<tr><td><tt><font color=#FF0000>Sun $i</font></tt></td><td width=80 bgcolor=#EFEFFF></td></tr>"
        continue
      fi
      if [ `echo "$lun" |grep -w -c $i` -ne 0 ]; then
        echo "<tr><td><tt>Mon $i</tt></td><td width=80 bgcolor=#EFEFFF></td></tr>"
        continue
      fi
      if [ `echo "$mar" |grep -w -c $i` -ne 0 ]; then
        echo "<tr><td><tt>Tue $i</tt></td><td width=80 bgcolor=#EFEFFF></td></tr>"
        continue
      fi
      if [ `echo "$mer" |grep -w -c $i` -ne 0 ]; then
        echo "<tr><td><tt>Wed $i</tt></td><td width=80 bgcolor=#EFEFFF></td></tr>"
        continue
      fi
      if [ `echo "$gio" |grep -w -c $i` -ne 0 ]; then
        echo "<tr><td><tt>Thu $i</tt></td><td width=80 bgcolor=#EFEFFF></td></tr>"
        continue
      fi
      if [ `echo "$ven" |grep -w -c $i` -ne 0 ]; then
        echo "<tr><td><tt>Fri $i</tt></td><td width=80 bgcolor=#EFEFFF></td></tr>"
        continue
      fi
      if [ `echo "$sab" |grep -w -c $i` -ne 0 ]; then
        echo "<tr><td><tt><font color=#CC00A0>Sat $i</font></tt></td><td width=80 bgcolor=#EFEFFF></td></tr>"
        continue
      fi
  done
  echo "</table></td>"
done
echo "</tr></table></body></html>"


exit 0