#!/bin/bash
ddir="kmanuale"
primo=1
ultimo=50
#add current path
PATH=$PATH:.

# first arg:  dir where HTMLs are;
# second arg: "points" to image dir
# third arg: points to text-image dir

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
  echo "$0 DIR_HTML DIR_IMG DIR_TXT"
  exit 1
fi

if [ ! -d $1 ] || [ ! -d $2 ] || [ ! -d $3 ]; then
  echo -e "$1\n$2\n$3\nmust be an existing dirs!"
  exit 1
fi

if [ ! -e $ddir ]; then
  mkdir $ddir || ( echo "error creating $ddir"; exit 1 )
fi

if [ ! -d $ddir ]; then
  echo "$ddir exists but it is not a dir!"
  exit 1
fi


mkdir $ddir/pos  || ( echo "error creating $ddir/pos"; exit 1 )
mkdir $ddir/pos/nomi || ( echo "error creating $ddir/pos/nomi"; exit 1 )
mkdir $ddir/pos/img || ( echo "error creating $ddir/pos/img"; exit 1 )

echo "<html><head><title>Kamasutra</title>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">" >$ddir/index.html
echo "</head><body>" >>$ddir/index.html

echo "<h1>Kamasutra</h1><h2>Indice delle posizioni</h2>" >>$ddir/index.html
echo "<ul>" >>$ddir/index.html
for i in `seq $primo $ultimo`
do
  echo "<li><a href=\"pos/pos${i}.html\"><img src=\"pos/nomi/titre${i}.gif\"></a>" >>$ddir/index.html
  cp $3/titre${i}.gif $ddir/pos/nomi
  cp $2/ill${i}.gif $ddir/pos/img

  #crea l'html della posizione.
  echo "<html><head><title>Posizione $i</title>
  <meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">" >$ddir/pos/pos${i}.html
  echo "</head><body><table><tr><td><img src=\"nomi/titre${i}.gif\"></td></tr>" >>$ddir/pos/pos${i}.html
  echo "<tr><td><img src=\"img/ill${i}.gif\"></td></tr></table>" >>$ddir/pos/pos${i}.html
  cat $1/${i}.html | estraitesto.pl |sed -e 's/<td>/<p>/;s|</td>|</p>|;s/<font[^>]*>//;s|</font>||' >>$ddir/pos/pos${i}.html
  echo "</body></html>" >>$ddir/pos/pos${i}.html
done

echo "</ul></body></html>" >>$ddir/index.html

exit 0