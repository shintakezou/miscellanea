#!/bin/bash
for el in $*
do
  if [ -d $el ]; then
    for f in `ls $el`
    do
      if [ ! -f $el/$f ]; then
        continue
      fi
      html=$( file $el/$f |egrep -c ': HTML' )
      img=$( file $el/$f |egrep -c ': JPEG' )
      if [ $html -eq 1 ] && [ $img -eq 0 ]; then
        echo "removing $el/$f"
        rm $el/$f >/dev/null 2>/dev/null
      elif [ $img -eq 1 ]; then
        isize=$( ls -l $el/$f |awk '{print $5}' )
        if [ $isize -lt 11000 ]; then
          echo "removing $el/$f: seems a thumbnail pic"
          rm $el/$f >/dev/null 2>/dev/null
        fi
      fi
    done
  fi
done
exit 0
