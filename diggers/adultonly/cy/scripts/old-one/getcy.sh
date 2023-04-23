#!/bin/bash
#IFS=" "
baseaddr="http://www.THE SITE"
purl='curl -A Mozilla/5.0 -L'
tmp=`mktemp tmp.XXXX`
fcookie="fcookie"
scookie="scookie"
log="cy.log"
tabufile="tabu.list"
rec=0

function zurl {
    if [ -e $fcookie ]; then
      $purl -b $fcookie -c $scookie $* >/dev/null 2>$tmp
      if [ -e $scookie ]; then
        mv -f $scookie $fcookie
      fi
    else
      $purl -c $fcookie $* >/dev/null 2>$tmp
    fi
}

function msg {
  if [ $1 -eq 0 ]; then
    echo "done"
  else
    echo "error"
    if [ -e $tmp ]; then
      cat $tmp
      rm $tmp
    fi
  fi
}

# - locale
# > downloaded
# T tabu
# D dir
# B browse (dal main)
function wlog {
  echo `date +%Y%m%d,%H%M%S::` $* >>$log
}


# enters from MAIN with pXXX/000.htm
# must extract from this 1) thumbs (NO), HTML file(s) of the kind
# NUMBER.htm(l), from this extracts inline images (src of img tag)
# then next is NUMBER-LETTER.htm(l), checkin that it is not the one
# we are analysing nor one of the previous: if working on 000b.htm,
# skip 000a.html since this comes before of 000b and so we surely
# have already analysed it.

function browse {
  local sindice
  local bas
  local nam
  local img
  local nest

  rec=$(( $rec + 1 ))
  # arg 1 = pXXX/000.htm
  # bas = pXXX
  bas=$( dirname $1 )
  nam=$( basename $1 )

  if [ ! -e $1 ]; then
    echo -n "get $1 ..."
    wlog "BROWSE $rec $LINENO > $1"
    zurl ${baseaddr}$1 -o $1
    msg $?
  fi

  for sindice in `cat $1 |getaddrs |egrep -v '^http://' |egrep -v '^\.\./' |egrep '[0-9]+\.htm$' |sort |uniq`
  do

    #if [ `echo "$bas/$sindice" |egrep -c -f $tabufile` -ne 0 ]; then
    #  wlog "BROWSE $rec $LINENO T $bas/$sindice"
    #  continue
    #fi

    if [ ! -e $bas/$sindice ]; then
      wlog "BROWSE $rec $LINENO > $bas/$sindice"
      echo -n "Downloading $bas/$sindice ..."
      zurl ${baseaddr}$bas/$sindice -o $bas/$sindice
    else
      wlog "BROWSE $rec $LINENO - $bas/$sindice"
    fi

    for img in `cat $bas/$sindice |ginlineimg |egrep -v '^http://' |egrep -v '\.\./' |sort |uniq`
    do
      #if [ `echo "$bas/$img" |egrep -c -f $tabufile` -ne 0 ]; then
      #  wlog "BROWSE $rec $LINENO T $bas/$img"
      #  continue;
      #fi

      if [ ! -e $bas/$img ]; then
        echo "img $img"
        wlog "BROWSE $rec $LINENO > $bas/$img"
        echo -n "Image $bas/$img ..."
        zurl ${baseaddr}$bas/$img -o $bas/$img
        msg $?
      else
        wlog "BROWSE $rec $LINENO - $bas/$img"
      fi

    done

  done

  for nest in `cat $1 |getaddrs |egrep -v '^http://' |egrep -v '\.\./' |egrep '[0-9]+[a-z]+\.htm[l]?$' |sort |uniq`
  do
    if [ "$nest" == "$1" ]; then
      continue
    fi
    if [ "$nest" < "$1" ] && [ "$nam" != "000.htm" ]; then
      continue
    fi

    #if [ `echo "$bas/$nest" |egrep -c -f $tabufile` -ne 0 ]; then
    #  wlog "BROWSE $rec $LINENO T $bas/$nest"
    #  continue
    #fi

    if [ ! -e $bas/$nest ]; then
      wlog "BROWSE $rec $LINENO N $bas/$nest"
      echo -n "Downloading $bas/$nest ..."
      zurl ${baseaddr}$bas/$nest -o $bas/$nest
      msg $?
    else
      wlog "BROWSE $rec $LINENO - $bas/$nest"
    fi

    browse $bas/$nest

  done

  wlog "BROWSE $rec $LINENO ***END"
  rec=$(( $rec - 1 ))

}

##MAIN
#

if [ ! -e $tabufile ]; then
  echo "^pippo$" >$tabufile
fi

echo -n "Connecting to $baseaddr to store cookies ..."
curl -c $fcookie $baseaddr >/dev/null 2>$tmp
msg $?

if [ ! -e index1.html ]; then
  echo -n "Downloading index1.html ..."
  wlog "MAIN $LINENO > index1.html"
  zurl ${baseaddr}index1.html -o index1.html
  msg $?
else
  wlog "MAIN $LINENO - index1.html"
fi

# index1 contains links to index200X.html
for indice in `cat index1.html |getaddrs |egrep -v '^http://' |egrep -v "^\.\./" |egrep '^index200[0-9]\.html$' |sort |uniq`
do
  if [ `echo "$indice" |egrep -c -f $tabufile` -eq 0 ]; then
    #echo DBG $indice
    if [ ! -e $indice ]; then
      wlog "MAIN $LINENO > $indice"
      echo -n "Downloading $indice ..."
      zurl ${baseaddr}$indice -o $indice
      msg $?
    else
      wlog "MAIN $LINENO - $indice"
    fi

    for pdir in `cat $indice |getaddrs |egrep -v '^http://' |egrep -v "^\.\./" |egrep 'p[a-z]*/00[0-1]\.htm[l]?$' |sort |uniq`
    do

      bdir=$( dirname $pdir )

      if [ `echo "$bdir" |egrep -c -f $tabufile` -eq 0 ]; then

        if [ ! -d $bdir ]; then
          wlog "MAIN $LINENO D $bdir"
          mkdir $bdir
        fi

        if [ ! -e $pdir ]; then

          wlog "MAIN $LINENO > $pdir"
          echo -n "Downloading $pdir ..."
          zurl ${baseaddr}$pdir -o $pdir
          msg $?

        else
          wlog "MAIN $LINENO - $pdir"
        fi

        wlog "MAIN $LINENO B $pdir"
        browse $pdir
        wlog "MAIN $LINENO B ----"

      else
        wlog "MAIN $LINENO T $pdir"
      fi

    done

  else
    wlog "MAIN $LINENO T $indice"
  fi
done

exit 0
