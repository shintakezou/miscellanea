#!/bin/bash

url="http://www.WRITE HERE A SITE"

# work offline?
offline=0

# to log or not to log
nolog=1

# explore all dirs?
alldir=1

# search dir?
searchdir=0

passa=0

fcookie="fcookie"
scookie="scookie"
purl='curl -A Mozilla/5.0 -L'

zurl() {
    if [ $offline -eq 1 ]; then
      echo "ERROR" >&2
      return
    fi
    if [ -e $fcookie ]; then
      $purl -b $fcookie -c $scookie $* >/dev/null 2>$tmp
      if [ -e $scookie ]; then
        mv -f $scookie $fcookie
      fi
    else
      $purl -c $fcookie $* >/dev/null 2>/dev/null
    fi
}

# arg: p.../index
# here p... must exist and index too!
browse() {
  local dp
  local bp
  local imind
  local rim
  local al
  local avolist
  local images
  local im
  local succ
  local suc

  dp=$( dirname $1 )
  bp=$( basename $1 )

  # 1 extracts numbers like 001, 002, that contains photos,
  #   avoiding parent links (preventing loops)

  shift
  imind=$( cat $dp/$bp |getaddrs |sort |uniq |egrep '^[0-9]+\.html?' )
  avolist="$* $bp"

  for rim in $imind
  do
    for al in $avolist
    do
      if [ "$rim" == "$al" ]; then
        continue 2
      fi
    done
    if [ ! -f $dp/$rim ]; then
      if [ $offline -eq 0 ]; then
        wlog -n "downloading $dp/$rim ..."
        zurl $url/$dp/$rim -o $dp/$rim
        if [ $? -ne 0 ]; then
          wlog "error"
          continue
        else
          wlog "done"
        fi
      else
        wlog "$dp/$rim does not exist"
        continue
      fi
    fi
    # if here, or the file dp/rim exists, or we have downloaded it...
    images=$( cat $dp/$rim |ginlineimg | sort |uniq |egrep -v '^http://' |egrep -v '^\.\./' |egrep '.*\.jpg' )
    for im in $images
    do
      if [ -f $dp/$im ]; then
        wlog "image $dp/$im exists"
      else
        if [ $offline -ne 0 ]; then
          wlog "image $dp/$im lacks"
        else
          wlog -n "downloading image $dp/$im ..."
          zurl $url/$dp/$im -o $dp/$im
          if [ $? -eq 0 ]; then
            wlog "done"
          else
            wlog "error"
          fi
        fi
      fi
    done
  done

  # 2 looking for next one
  succ=$( cat $dp/$bp |getaddrs |sort |uniq |egrep '^[0-9]+[a-z]+\.html?' )

  for suc in $succ
  do
    for al in $avolist
    do
      if [ "$suc" == "$al" ]; then
        continue 2
      fi
    done
    if [ -f $dp/$suc ]; then
      wlog "next for $dp is $dp/$suc"
      browse $dp/$suc $avolist
    else
      if [ $offline -eq 0 ]; then
        wlog -n "downloading $dp/$suc"
        zurl $url/$dp/$suc -o $dp/$suc
        if [ $? -ne 0 ]; then
          wlog "error"
        else
          wlog "done"
          browse $dp/$suc $avolist
        fi
      else
        wlog "$dp/$suc does not exist"
      fi
    fi
  done

}

aiuto() {
  echo "
$0 searchdir/s,index/a,offline/s,log/k,dir/k,pass/s

searchdir          search for a dir. Index/a can be a list of indexes,
                   and dir keyword must be given
index              one index file; a list can be given for searchdir mode
offline            offline mode
log=LOG            set LOG as log file
dir=DIR            check (offline), download or search for this DIR
pass               in searchdir mode, once the dir is found in a specific
                   index, download it (offline mode disabled)
"
}

wlog() {
  echo $* >&2
  if [ $nolog -eq 1 ]; then
    return
  fi
  if [ "$1" == "-n" ]; then
    shift
  fi
  echo `date +"%Y-%m-%d %H:%M:%S"` $* >>$log
}

for arg in $*
do
  case $arg in
    pass) passa=1
          ;;
    searchdir) searchdir=1
               offline=1
               ;;
    offline) offline=1
       ;;
    log=*) nolog=0
           log=$( echo $arg |sed -e 's/^log=//' )
           ;;
    dir=*) alldir=0
           nomedir=$( echo $arg |sed -e 's/^dir=//' )
           ;;
    ?) aiuto
        exit 0
        ;;
    *) if [ $searchdir -eq 1 ]; then
         indexfile="$indexfile $arg"
       else
         indexfile="$arg"
       fi
      ;;
  esac
done

if [ "$indexfile" == "" ]; then
  aiuto
  exit 0
fi

if [ $searchdir -eq 0 ] && [ ! -e $indexfile ]; then
  echo "cannot find $indexfile" >&2
  exit 0
fi

if [ $nolog -eq 0 ] && [ "$log" == "" ]; then
  log="getidx.log"
fi

if [ $alldir -eq 0 ] && [ "$nomedir" == "" ]; then
  echo "you must give a dir name for dir keyword" >&2
  exit 0
fi

if [ $searchdir -eq 1 ] && [ "$nomedir" == "" ]; then
  echo "specify a dir to be searched"  >&2
  exit 0
fi

#---------------------------------------------------

if [ $searchdir -eq 1 ]; then
  for fin in $indexfile
  do
    ishere=$( cat $fin |getaddrs |sort |uniq |egrep -v ^http:// |egrep -v ^\.\./ |egrep -c ^$nomedir/ )
    if [ $ishere -ne 0 ]; then
      echo "$fin"
      if [ $passa -eq 0 ]; then
        exit 0
      else
        offline=0
        indexfile="$fin"
        break
      fi
    fi
  done
fi

if [ $offline -eq 0 ]; then
  temp="`mktemp tmp.$$.XXXXX`"
  zurl $url -o $temp
  if [ $? -ne 0 ]; then
    offline=1
  fi
  rm $temp >/dev/null 2>/dev/null
fi

if [ $offline -eq 1 ]; then
  if [ $alldir -eq 1 ]; then
    wlog "Offline mode, exploring all dirs"
  else
    wlog "Offline mode, exploring $nomedir"
  fi
else
  if [ $alldir -eq 1 ]; then
    wlog "Online mode, exploring all dirs"
  else
    wlog "Online mode, exploring $nomedir"
  fi
fi

dirlist=$( cat $indexfile |getaddrs |sort |uniq |egrep '^p.*/00[01]\.html?' )
dirviste=0

  for indice in $dirlist
  do
    dnome=$( dirname $indice )
    inome=$( basename $indice )

    if [ $alldir -ne 1 ]; then
      if [ "$dnome" != "$nomedir" ]; then
        continue
      fi
    fi

    dirviste=$(($dirviste + 1))

    if [ -d $dnome ]; then
      if [ -f $indice ]; then
        browse $indice
      else
        if [ $offline -eq 1 ]; then
          wlog "$indice does not exist. Looking for next dir"
        else
          wlog -n "downloading $indice ..."
          zurl $url/$indice -o $indice
          if [ $? -ne 0 ]; then
            wlog "error"
          else
            wlog "done"
            browse $indice
          fi
        fi
      fi
    else
      if [ $offline -eq 1 ]; then
        wlog "$dnome does not exist. Looking for next dir"
      else
        mkdir $dnome
        if [ $? -ne 0 ]; then
          wlog "cannot create $dnome"
        else
          wlog -n "downloading $indice ..."
          zurl $url/$indice -o $indice
          if [ $? -eq 0 ]; then
            wlog "done"
            browse $indice
          else
            wlog "error"
          fi
        fi
      fi
    fi
  done

if [ $alldir -eq 0 ] && [ $dirviste -eq 0 ]; then
  wlog "dir $nomedir was not found in $indexfile"
fi

exit 0
