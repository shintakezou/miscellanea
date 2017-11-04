#!/bin/bash

# GPL
# (C)2006 Mauro Panigada

# use: asciilist.sh 32
# to write a space...
# asciilist.sh 69 32 70
# to write two ASCII letter and a space...

for nume in $@
do
 #printf "%c" $nume
 xnume=$( printf "\\ x%x" $nume | sed -e 's/ //g')
 echo -ne "$xnume"
done
echo ""