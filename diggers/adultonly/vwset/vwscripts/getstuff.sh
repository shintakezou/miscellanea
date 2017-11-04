#!/bin/bash
#autocheck for not unique resources
. filenames

echo "Checking for non-unique..."
uniquecheck.sh
echo "Done."

echo "Downloading..."
wget -E -H -k -K -p -i $STUFFILE
cat $STUFFILE >> $DOWNFILE
rm $STUFFILE
echo "Done."
purgelist.sh

exit 0

