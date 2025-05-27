#!/bin/bash
# vwdigger.sh
#
# downloads:
#
# ***.*********.com/main/Picturep.html
# ***.************.com/main/Picturep.html
# ***.*********.com/main/Pictures.html
#
# extracts "interesting" links that puts into a list (a file)
#
# then extracts links from this list (by default, 10) and puts them
# into the going-to-be-downloaded list; if the option nodownload is not
# present, the download starts; downloaded files are put into a downloaded
# list so that won't be donwloaded twice the next time you run vwdigger.
#
# updates a global downloaded list...
#
# the local option allows to specify a local file, so that the list can
# be generated offline (with the nodownload opt); with @ as argument,
# open kdialog (you need KDE for this)
#
# the TABU list stores url that must be ignored
#
. filenames

TMP1=`mktemp tmp.XXXXXXXX`
TMP2=`mktemp tmp.XXXXXXXX`
TMP3=`mktemp tmp.XXXXXXXX`
ORIG=`pwd`
NUMOFLINKS=10
DOWNFLAG=1
INPUTFLAG=0
THEBASE=http://***.*********.com/main

if [ ! -e $STUFFILE ]
then
  echo "" > $STUFFILE
fi

for argu in "$@"
do
  case $argu in
    local=*)
      THEINPUT=`echo $argu |sed -e 's/local=//'`
      INPUTFLAG=1
      echo "Link will be taken from file $argu"
      ;;
    base=*)
      THEBASE=`echo $argu |sed -e 's/base=//'`
      echo "The base url will be $argu"
      ;;
    new)
      echo "The list will be dowloaded, $THELIST deleted"
      rm $THELIST
      ;;
    nodownload)
      echo "Offline mode activated"
      DOWNFLAG=0
      ;;
    link=*)
        NUMOFLINKS=`echo $argu |sed -e 's/link=//'`
        echo "Number of links set to $NUMOFLINKS"
      ;;
    human)
        # not implemented
        HUMAN=1
       ;;
  esac
done

echo ""

if [ "$INPUTFLAG" == "1" ]
then
  if [ "$THEINPUT" == "@" ]; then
    THEINPUT=`kdialog --getopenfilename $HOME "*"`
    if [ $? == 1 ]; then
      THEINPUT=@
    fi
  fi
  echo "Extracting links from $THEINPUT ..."
  cat $THEINPUT | nocr.pl | getaddrs.pl |grep index.html$ |sort |uniq > $TMP1
  cat $TMP1 | grep -v ^http:// > $TMP2
  #ora per ogni riga devo aggiungere in testa THEBASE...
  echo "Adding $THEBASE for relatives URLs ..."
  for elem in `cat $TMP2`
  do
    TRAIL=$( echo $THEBASE | sed -e 's/\/$//' )
    QUEUE=$( echo $elem | sed -e 's/^\///' )
    echo $TRAIL/$QUEUE >> $THELIST
  done
  cat $TMP1 | grep http:// >> $THELIST
  rm $TMP1
  rm $TMP2
fi

if [ ! -e $THELIST ]
then
  echo -n "Downloading index pages ... "
  mkdir $TMP1  || exit 1
  cd $TMP1

  echo -n "*"
  wget -q -k -nd http://***.*********.com/main/Picturep.html --referer http://***.*********.com

  echo -n "*"
  wget -q -k -nd http://***.************.com/main/Picturep.html --referer http://***.*********.com

  echo -n "* "
  wget -q -k -nd http://***.*********.com/main/Pictures.html --referer http://***.*********.com
  cd $ORIG
  echo "Done."

  echo "Selecting interesting URLs ..."
  cat $TMP1/* | nocr.pl | getaddrs.pl |grep index.html$ | sort | uniq > $THELIST

  rm $TMP1/*
  rmdir $TMP1
else
  echo "Sorting and making $THELIST's elements unique ..."
  cat $THELIST | sort |uniq > $TMP2
  mv -f $TMP2 $THELIST
fi

echo "Deleting URLs already downloaded or in the taboo list ..."
cat $DOWNFILE $TABU > $TMP3
grep -v -f $TMP3 $THELIST > $TMP1
rm $TMP3
mv -f $TMP1 $THELIST

echo "Queueing $NUMOFLINKS into $STUFFILE ..."

head -n $NUMOFLINKS $THELIST > $TMP2
cat $TMP2 $STUFFILE |sort |uniq > $TMP1
rm $TMP2
mv -f $TMP1 $STUFFILE

if [ "$DOWNFLAG" == "1" ]
then
  echo "Dowloading data. WGET output follows:"
  wget -E -H -k -K -p -i $STUFFILE
  # a wget terminato, la stufflist passa in downloaded, il file stufffile viene eliminato
  cat $STUFFILE >> $DOWNFILE
  rm $STUFFILE
  echo "Done."
  purgelist.sh
else
  echo "Done."
fi
