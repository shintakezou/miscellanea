#!/bin/bash
#IFS=" "
baseaddr="http://www.THE SITE"
purl='curl -A Mozilla/5.0 -L'
tmp=`mktemp tmp.XXXX`
fcookie="fcookie"
scookie="scookie"
log="cy.log"

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
    exit 1
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
  mdir=$( dirname $1 )

  for findice in `cat $1 |getaddrs |egrep "[0-9]*\.htm$"`
  do

    if [ -e $mdir/$findice ]; then continue ; fi

    wlog "rec=$rec download $findice at $mdir"
    echo -n "Downloading ${baseaddr}$mdir/$findice"
    zurl ${baseaddr}$mdir/$findice -o $mdir/$findice
    msg $?

    for fot in `cat $mdir/$findice |getaddrs |egrep '[0-9]*\.htm$'`
    do

      if [ -e $mdir/$fot ]; then continue ; fi

      wlog "rec=$rec single html index page $fot"
      echo -n "Downloading ${baseaddr}$mdir/$fot ..."
      zurl ${baseaddr}$mdir/$fot -o $mdir/$fot
      msg $?

      for timg in `cat $mdir/$fot |ginlineimg |egrep '.*\.jpg$'`
      do

        if [ -e $mdir/$timg ]; then continue ; fi

        wlog "rec=$rec image $mdir/$timg"
        echo -n "Image $timg ..."
        zurl ${baseaddr}$mdir/$timg -o $mdir/$timg
        msg $?
      done

    done

    for next in `cat $mdir/$findice |getaddrs |egrep '[0-9]*[a-z][a-z]*\.htm$'`
    do
      wlog "rec=$rec entering new level"
      rec=$(( $rec + 1 ))
      browse $mdir/$next
      wlog "rec=$rec exiting this level"
      rec=$(( $rec - 1 ))
    done

  done
}

##MAIN
#

if [ ! -d pic ];then
  mkdir pic || exit 1
fi

echo "Dir 'pic' created."
echo -n "Connecting to store cookies ..."
curl -c $fcookie $baseaddr >/dev/null 2>$tmp
msg $?

echo -n "Downloading index1.html ..."
wlog ${baseaddr}index1.html
zurl ${baseaddr}index1.html -o index1.html
msg $?

for indici in `cat index1.html |getaddrs |egrep "index200[0-9]\.html$" |sort |uniq`
do
  echo -n "Downloading $indici ..."

  wlog ${baseaddr}$indici
  zurl ${baseaddr}$indici -o $indici
  msg $?

  for sindice in `cat $indici |getaddrs |egrep "p[a-z]*/00[0-9]\.htm$" |sort |uniq`
  do
    bdir=$( dirname $sindice )
    if [ ! -d $bdir ]; then
      echo "Creating dir $bdir"
      mkdir $bdir
      wlog "creating $bdir"
    fi
    if [ ! -e $sindice ]; then
      echo -n "Downloading $sindice ..."
      wlog ${baseaddr}$sindice
      zurl ${baseaddr}$sindice -o $sindice
      msg $?
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
