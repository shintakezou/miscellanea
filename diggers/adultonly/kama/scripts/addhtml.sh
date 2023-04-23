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

for f in $1/*
do
  if [ -f $f ]; then
    mv $f $f.html
  fi
done

exit 0
