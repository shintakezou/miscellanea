#!/bin/bash

# get - a simple script that downloads links stored into a file
# (C)2007 Mauro Panigada
# GPL

# NEED wget


# the file links are stored into. finer if you can specify this in the
# command line
reffile="links.txt"

# a base url, if links are relative to; it could be the http://
# prefix or whatsoever
url=""

# destination dir.
ddir="download"


# we trap userbreak so that if there are still links, they can be
# downloaded later.
userbreak()
{
  stato=1
  numero=0
  echo "*** User break" >&2
}

trap 'userbreak' SIGHUP SIGINT SIGABRT SIGQUIT SIGTERM

# remember prev dir.
dirc=$( pwd )

if [[ ! -e "$ddir" ]]; then
  mkdir "$ddir" && cd "$ddir"
else
  cd "$ddir"
fi

stato=0
if [[ "$1" != "" ]]; then
  stato=1
  numero=$1
  if [[ $numero -lt 1 ]]; then
    numero=1
  fi
fi

while read linea
do
  if [[ $stato -eq 0 ]]; then
     wget -w 1 --random-wait -kKpHE "$url/$linea"
     sleep 1s
  elif [[ $numero -gt 0 ]]; then
     wget -w 1 --random-wait -kKpHE "$url/$linea"
     sleep 1s
     numero=$(( $numero - 1 ))
  else
     echo "$linea" >>"../${reffile%.txt}_next.txt"
  fi
done <"../$reffile"

if [[ -f "../${reffile%.txt}_next.txt" ]]; then
  mv "../$reffile" "../${reffile%.txt}-$(date +%Y%m%d).old"
  mv "../${reffile%.txt}_next.txt" "../$reffile"
fi

cd "$dirc"

exit 0
