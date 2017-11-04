#!/bin/bash
# update the specified site
# it's the dir (inside $HOME/public_html)
# where you must have a .admin drawer with connection's data
# and other details.
# your sites are supposed to be inside $HOME/public_html

if [[ "$1" == "" ]]; then
  echo "Specify a local site dir!" >&2
  exit 1
fi
site="$1"

# local for all sites is $HOME/public_html
locale="$HOME/public_html/$site"

if [[ ! -d "$locale/.admin" ]]; then
  echo "You need a .admin drawer with all infos inside" >&2
  exit 1
fi

if [[ ! -f "$locale/.admin/Connect" ]]; then
  echo "You need connection data!" >&2
  exit 1
fi

. $locale/.admin/Connect


if [[ "$2" == "exec" ]]; then
  job="updater.$$"
else
  job="/dev/stdout"
fi


if [[ ! -f "$locale/.admin/UPDATE" ]]; then
  echo "nothing up-to-date" >&2
  exit 0
fi


echo "open -u $usr,$psw -p 21 ftp://$url" >$job
echo "lcd $locale" >>$job
echo "cd $rdir" >>$job


while read line; do
  line=$( echo "$line" | sed -e 's/^ \+//' -e 's/ \+$//')
  if [[ "$line" == "" ]]; then
    continue;
  fi
  multi=$( echo "$line" |egrep -c '\*|\[|\]' )
  spec=$( echo "$line" |egrep -c '^!' )
  if [[ "$spec" == "1" ]]; then
     echo "$line" |sed -e 's/^![ ]*//' >>$job
     continue
  fi
  ddir=$( dirname "$line" )
  if [[ "$multi" != "0" ]]; then
    str="mput"
  else
    str="put"
  fi
  if [[ "$ddir" == "." ]]; then
    strop=""
  else
    strop="-O $ddir"
  fi
  str="$str $strop $line"
  echo "$str" >>$job
done <$locale/.admin/UPDATE


if [[ "$2" == "exec" ]]; then
   lftp -f "$job"
   err="$?"
   rm "$job"
   mv "$locale/.admin/UPDATE" "$locale/.admin/UPDATE.`date +%Y%m%d`"
   date --iso-8601=seconds >"$locale/.admin/LastUpdate"
   echo
   echo "--- everything ${err}k"
fi

exit 0
