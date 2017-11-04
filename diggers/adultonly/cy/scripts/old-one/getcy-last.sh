#!/bin/bash
#IFS=" "
#20051021
baseaddr="http://www.THE SITE"
purl='curl -A Mozilla/5.0 -L'
tmp=`mktemp tmp.XXXX`
fcookie="fcookie"
scookie="scookie"
log="cy.log"
tabufile="tabu.list"

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
    echo -n "Continue? [Y/n]: "
    read cont
    if [ "$cont" == "n" ]; then
      wlog "rec=$rec stopped for error"
      echo "Stopped."
      exit 1
    fi
  fi
}

function wlog {
  echo `date +%Y%m%d,%H%M%S::` $* >>$log
}

function browse {
  local mdir
  local findice
  local fot
  local timg
  local nest
  mdir=$( dirname $1 )

  for findice in `cat $1 |getaddrs |egrep "[0-9]+\.htm[l]?$" | egrep -v "^http://" |egrep -v "^\.\./"`
  do

    if [ -e $mdir/$findice ]; then
      echo "$mdir/$findice found! Using local file!"
      wlog "rec=$rec local $mdir/$findice"
    else

      wlog "rec=$rec download $findice at $mdir"
      echo -n "Downloading ${baseaddr}$mdir/$findice ..."
      zurl ${baseaddr}$mdir/$findice -o $mdir/$findice
      msg $?
    fi

    for fot in `cat $mdir/$findice |ginlineimg |egrep '.*\.jpg'`
    do

      if [ -e $mdir/$fot ]; then
        wlog "rec=$rec $mdir/$fot exists"
      else
        wlog "rec=$rec image $fot of $mdir"
        echo -n "Image ${baseaddr}$mdir/$fot ..."
        zurl ${baseaddr}$mdir/$fot -o $mdir/$fot
        msg $?
      fi
    done

    for fot in `cat $mdir/$findice |getaddrs |egrep '[0-9]+\.htm[l]?$' |egrep -v ^http:// |egrep -v "^\.\./"`
    do

      if [ -e $mdir/$fot ]; then
        wlog "rec=$rec $mdir/$fot exists!"
      else

        wlog "rec=$rec single html index page $fot"
        echo -n "Downloading ${baseaddr}$mdir/$fot ..."
        zurl ${baseaddr}$mdir/$fot -o $mdir/$fot
        msg $?
      fi

      for timg in `cat $mdir/$fot |ginlineimg |egrep '.*\.jpg$' |egrep -v '^http://' |egrep -v "^\.\./"`
      do

        if [ -e $mdir/$timg ]; then
          wlog "rec=$rec $mdir/$timg exists!"
        else

          wlog "rec=$rec image $mdir/$timg"
          echo -n "Image $timg ..."
          zurl ${baseaddr}$mdir/$timg -o $mdir/$timg
          msg $?
        fi
      done

    done

  done
    #wlog "rec=$rec check for next in $mdir/$findice"
    #echo "cat $mdir/$findice bla bla"
    #cat $mdir/$findice |getaddrs |egrep '[0-9]+[a-z][a-z]*\.htm[l]?$' |grep -v '^http://' |egrep -v "^\.\./"

    # cat $mdir/$findice
    for nest in `cat $1 |getaddrs |egrep '[0-9]+[a-z][a-z]*\.htm[l]?$' |grep -v '^http://' |egrep -v "^\.\./"`
    do
      if [ "$nest" != "$1" ]; then
        if [ "$nest" > "$1" ]; then

          wlog "rec=$rec entering new level"
          rec=$(( $rec + 1 ))
          browse $mdir/$nest
          wlog "rec=$rec exiting this level"
          rec=$(( $rec - 1 ))
        fi
      fi
    done

  #check for images... delete those ending in s before jpg (s=small?)
  for fot in `cat $1 |ginlineimg |egrep ".*[^s]\.jpg$"`
  do
    if [ -e $mdir/$fot ]; then
      wlog "rec=$rec $mdir/$fot exists!"
    else
      wlog "rec=$rec image $mdir/$fot"
      echo -n "Image $fot ..."
      zurl ${baseaddr}$mdir/$fot  -o $mdir/$fot
      msg $?
    fi
  done

}

##MAIN
#

#if [ ! -d pic ];then
#  mkdir pic || exit 1
#fi

echo -n "Connecting to store cookies ..."
curl -c $fcookie $baseaddr >/dev/null 2>$tmp
msg $?

if [ -e $tabufile ]; then
  echo "Using $tabufile"
fi

if [ -e index1.html ]; then
  echo "index1.html found! Using local file!"
  wlog "local index1.html"
else
  echo -n "Downloading index1.html ..."
  wlog ${baseaddr}index1.html
  zurl ${baseaddr}index1.html -o index1.html
  msg $?
fi

for indici in `cat index1.html |getaddrs |egrep "index200[0-9]\.htm[l]?$" |sort |uniq`
do


  #if [ `echo "$indici" |egrep -c -f $tabulist` -ne 0 ]; then
  #  continue
  #fi

    if [ -e $indici ]; then
      echo "Index $indici found! Using local file!"
      wlog "local $indici"
    else
      echo -n "Downloading $indici ..."
      wlog ${baseaddr}$indici
      zurl ${baseaddr}$indici -o $indici
      msg $?
    fi

  for sindice in `cat $indici |getaddrs |egrep "p[a-z]*/00[0-9]\.htm[l]?$" |sort |uniq |egrep -v '^http://'`
  do
    bdir=$( dirname $sindice )

    #if [ `echo "$indici" |egrep -c -f $tabulist` -ne 0 ]; then
    #  continue
    #fi

    if [ ! -d $bdir ]; then
      echo "Creating dir $bdir"
      mkdir $bdir
      wlog "creating $bdir"
    else
      echo "$bdir already exists! Lookin' in it"
    fi
    if [ ! -e $sindice ]; then
      echo -n "Downloading $sindice ..."
      wlog ${baseaddr}$sindice
      zurl ${baseaddr}$sindice -o $sindice
      msg $?
    else
      echo "$sindice exists! Using local file!"
      wlog "local $sindice"
    fi
    rec=0
    wlog "rec=$rec entering browse for $sindice"
    browse $sindice
    echo "Next p*** index."
  done
done
rm $tmp >/dev/null 2>/dev/null
echo "All done."
wlog "***END"
exit 0
