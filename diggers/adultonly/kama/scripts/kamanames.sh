#!/bin/bash

#converte i nomi

if [ "$1" == "" ]; then
  echo "give me a dir"
  exit 1
fi

if [ ! -d $1 ]; then
  echo "$1 must be an existing dir"
  exit 1
fi

for f in $1/*.html
do
  # f=$( echo "$f" |sed -e 's/?/\\?/g;s/=/\\=/g' )
  nn="` echo $f |sed -e 's/^.*numero=\([0-9]\+\)\.html/\1/' `"
  mv $f $1/$nn
done

exit 0
