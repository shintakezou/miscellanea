#! /bin/bash

Help()
{
  echo -e "marc.sh - handle cpio archive of gzipped/bzipped files

marc.sh ACTION [OPTIONS] ARCHIVE [FILES]

ACTION:
\tlist\t\tlist contents of the ARCHIVE
\tcreate\t\tcreate archive ARCHIVE with FILES (or DIR) (see options)
\textract\t\textract FILES (matching pattern) from ARCHIVE

OPTIONS:
\t-j\t\tuses bzip2 rather than gzip
\t-v\t\tprint info to stderr
\t-t DIR\t\ta temporary directory

Read the documentation this file came with to know more.
";
exit 0
}

logg()
{
  if [[ $debug -eq 1 ]]; then
    echo $@ >&2
  fi
}

usebzip=0
action=""
archive=""
filelist=""
debug=0
ecru="gzip"
suffix=".gz"


while [[ $OPTIND -le $# ]]; do
  while getopts "jvt:" opzione ; do
    case $opzione in
      j) usebzip=1
         ecru="bzip2"
         suffix="bz2"
         ;;
      v) debug=1 ;;
      t) temp="$OPTARG" ;;
      ?) Help  ;;
    esac
  done
  if [[ "$action" == "" ]]; then
    action=${!OPTIND}
  elif [[ "$archive" == "" ]]; then
    archive=${!OPTIND}
  else
    filelist="$filelist${!OPTIND}
"
  fi
  OPTIND=$(( $OPTIND + 1 ))
done

if [[ "$action" == "" ]] || [[ "$archive" == "" ]]; then
  Help
fi

if [[ ! -w /var/tmp ]] && [[ "$temp" == "" ]] && [[ "$action" == "create" ]]; then
   echo "I have no access to /var/tmp... specify where I can write!" >&2
   exit 1
elif [[ "$temp" == "" ]]; then
  temp="/var/tmp"
fi

case $action in
  list) ;;
  create) ;;
  extract) ;;
  *) Help ;;
esac

if [[ "$action" != "create" ]] && [[ ! -f "$archive" ]]; then
  echo "File \"$archive\" not found" >&2
  exit 1
fi

logg "Action: $action"
logg "Archive: $archive"
logg "Using:" $( if [[ $usebzip -eq 1 ]]; then echo "bzip2"; else echo "gzip" ; fi)
logg "Temporary dir: $temp"
logg "Date:" $( date --iso-8601=s )

IFS="
"
case $action in
  create)
           thetemp=$(mktemp "$temp/marc$$.XXXXXXXX")
           for elemento in $filelist ; do
             if [[ -f "$elemento" ]]; then
                  crunc=$( file "$elemento" |egrep -ic "compressed|JPEG|GIF|PNG|audio" )
                  nome="$elemento"
                  if [[ $crunc -eq 0 ]]; then
                    lungh=$(ls -l "$elemento" |gawk '{ print $5; }')
                    if [[ $lungh -lt 600 ]]; then
                      $nome="$elemento"
                    else
                      $ecru "$elemento" >/dev/null 2>/dev/null
                      nome="$elemento$suffix"
                    fi
                  fi
                  echo "$nome" >>"$thetemp"
                  logg "Added file: $elemento"
             elif [[ -d "$elemento" ]]; then
                  find "$elemento" -depth -type f -exec file {} \; |egrep -iv "compressed|JPEG|GIF|PNG|audio" \
                        | sed -e 's/:.*$//g' >"${thetemp}2"
                  find "$elemento" -depth -type f -exec file {} \; |egrep -i "compressed|JPEG|GIF|PNG|audio" \
                        | sed -e 's/:.*$//g' >>"${thetemp}"
                  while read linea ; do
                    if [[ $(ls -l "$linea" |gawk '{print $5;}') -lt 600 ]]; then
                        echo "$linea" >>"$thetemp"
                    else
                      $ecru "$linea" >/dev/null
                      echo "$linea$suffix" >>"$thetemp"
                    fi
                  done <"${thetemp}2"
                  rm "${thetemp}2"
                  logg "Added full dir: $elemento"
             fi
           done
           cat "$thetemp" |cpio -o >"$archive"
           logg "Created \"$archive\"..."
           logg "Decrunching back to the original..."
           while read linea ; do
              if [[ $(echo "$linea" |egrep -c "$suffix$") -ne 0 ]]; then
                 $ecru -d "$linea"
              fi
           done < "$thetemp"
           rm "$thetemp"
    ;;
  list)
           if [[ $(file "$archive" |egrep -c cpio) -eq 0  ]]; then
             echo "\"$archive\" seems not a cpio archive..." >&2
             exit 1
           fi
           cpio -tv <"$archive"
    ;;
  extract)
           thetemp=$(mktemp "$temp/marc$$.XXXXXXXX")
           if [[ $(file "$archive" |egrep -c cpio) -eq 0 ]]; then
             echo "\"$archive\" seems not a cpio archive..." >&2
             exit 1
           fi
           #logg "*** $archive, $thetemp"
           cpio -tv <"$archive"  |egrep ^-  |gawk '{ print $9; }'  >"$thetemp"
           cpio -id <"$archive"
           while read linea ; do
              if [[ "$linea" == "" ]]; then
                continue
              fi
              tipo=$(file "$linea")
              gzippo=$(echo "$tipo" |egrep -ic 'gzip')
              if [[ $gzippo -eq 0 ]]; then
                bzippo=$(echo "$tipo" |egrep -ic 'bzip2')
                if [[ $bzippo -ne 0 ]]; then
                  ecrunc="bzip2"
                fi
              else
                ecrunc="gzip"
              fi
              if [[ $gzippo -ne 0 ]] || [[ $bzippo -ne 0 ]]; then
                 $ecrunc -d "$linea" 2>/dev/null
                 logg "Decompressing \"$linea\""
              fi
              logg "File \"$linea\" in safe!"
           done <"$thetemp"
           rm "$thetemp"
           echo "\"$archive\" decrunched..."
    ;;
esac
