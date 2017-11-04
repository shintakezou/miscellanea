#!/bin/bash
# catch 0-long files, and images.html
for el in `find . -type f`
do
  len=$( ls -l $el |awk '{ print $5 }' )
  if [ "$len" -eq 0 ]; then
    echo "Removing $el"
    rm $el
  fi
  if [ "`basename $el`" == "images.html" ]; then
    echo "Removing $el"
    rm $el
  fi
done

exit 0