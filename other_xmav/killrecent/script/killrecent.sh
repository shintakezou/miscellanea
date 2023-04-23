#!/bin/bash

dove="$HOME/.kde/share/config"

elenco=`find $dove -type f -iname "*rc"`
elenco="$elenco
`find $dove -type f -iname "*.new"`
$dove/kdeglobals"

for el in $elenco ;
do
  if [[ $(cat $el |grep -c "^Recent") != "0" ]]; then
    echo "File \"$el\" contains Recent!"
    echo "  killing Recent!"
    if [[ ! -d ".recent-backup" ]]; then
      echo "*** creating .recent-backup"
      mkdir .recent-backup
    fi

    cp $el .recent-backup
    nome=$(basename $el)
    cat .recent-backup/$nome |grep -v "^Recent" >$el
  fi
done

echo '`rm -R .recent-backup` for removing backup.'

exit