#!/bin/bash
#IFS=" "
tabufile="tabu.list"
rec=0
indenta=1

function browse {
  local sindice
  local bas
  local nam
  local img
  local nest

  rec=$(( $rec + 1 ))
  indenta=$(( $indenta+1))

  bas=$( dirname $1 )
  nam=$( basename $1 )

  if [ ! -e $1 ]; then
    echo "no $1"
    rec=$(( $rec - 1 ))
    indenta=$(( $indenta-1))
    return
  fi

  for sindice in `cat $1 |getaddrs |egrep -v '^http://' |egrep -v '^\.\./' |egrep '[0-9]+\.htm$' |sort |uniq`
  do

    if [ ! -e $bas/$sindice ]; then
      dici "$rec no $bas/$sindice"
      #rec=$(( $rec - 1 ))
      indenta=$(( $indenta-1))
      continue
    else
      dici "$rec $bas/$sindice found"
      indenta=$(($indenta+1))
    fi

    for img in `cat $bas/$sindice |ginlineimg |egrep -v '^http://' |egrep -v '\.\./' |sort |uniq`
    do

      if [ ! -e $bas/$img ]; then
         dici "$rec no $bas/$img"
      else
        dici "$rec $bas/$img found"
      fi

    done

  done


  dici "$rec Next..."
  indenta=$(($indenta+1))
  for nest in `cat $1 |getaddrs |egrep -v '^http://' |egrep -v '\.\./' |egrep '[0-9]+[a-z]+\.htm[l]?$' |sort |uniq`
  do
    echo "nest $nest - arg $1 - nam $nam"
    if [[ "$nest" == "$nam" ]]; then
      continue
    fi
    if [[ "$nam" != "000.htm" ]] && [[ "$nam" != "001.htm" ]]; then
      if [[ "$nest" < "$nam" ]]; then
        dici "$rec $nest skipped"
        continue
      fi
    else
      continue
    fi
    dici "$rec $nest good"

    if [ ! -e $bas/$nest ]; then
      dici "$rec $bas/$nest does not exist"
    else
      dici "$rec $bas/$nest exists"
    fi

    browse $bas/$nest

  done
  indenta=$(($indenta-1))

  rec=$(( $rec - 1 ))

}

function dici {
  echo $indenta $*
}

##MAIN
#

if [ ! -e $tabufile ]; then
  echo "^pippo$" >$tabufile
fi


if [ ! -e index1.html ]; then
  dici "no index1.html"
  exit 1
else
  dici "index1.html"
  indenta=$(( $indenta +1))
fi


for indice in `cat index1.html |getaddrs |egrep -v '^http://' |egrep -v "^\.\./" |egrep '^index200[0-9]\.html$' |sort |uniq`
do
  if [ `echo "$indice" |egrep -c -f $tabufile` -eq 0 ]; then
    dici "$indice allowed"
    indenta=$(($indenta+1))

    if [ ! -e $indice ]; then
      dici "no $indice"
      indenta=$(($indenta-1))
      continue
    else
      dici "$indice exists"
      indenta=$(($indenta+1))
    fi

    for pdir in `cat $indice |getaddrs |egrep -v '^http://' |egrep -v "^\.\./" |egrep 'p[a-z]*/00[0-1]\.htm[l]?$' |sort |uniq`
    do

      bdir=$( dirname $pdir )

      if [ `echo "$bdir" |egrep -c -f $tabufile` -eq 0 ]; then

        dici "$bdir allowed"

        if [ ! -d $bdir ]; then
          dici "no $bdir"
          indenta=$(($indenta-1))
          continue
        fi

        dici "$bdir exists"
        indenta=$(($indenta+1))

        if [ ! -e $pdir ]; then

          dici "no $pdir"
          indenta=$(($indenta-1))
          continue

        else
          dici "$pdir exists"
          indenta=$(($indenta+1))
        fi


        browse $pdir
        indenta=$(($indenta-1))

      else
        dici "$bdir forbidden"
        indenta=$(($indenta-1))
      fi

    done

  else
    dici "$indice forbidden"
    indenta=$(($indenta-1))
  fi
done

dici "end"

exit 0
