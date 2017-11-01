#! /bin/bash

##
# default theme, because I suppose other leaked emails can be got the same way
theme=${2:-hackingteam}
# email id
eid=$1
##

if [[ -z "$eid" ]]; then
    exit 1
fi

mkdir $eid || exit 1
pushd $eid

# change user agent as you like
wget -U "Mozilla/5.0 (X11; Linux i686) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.99 Safari/537.36" \
     "https://wikileaks.org/${theme}/emails/emailid/$eid" -O- |xmllint --html --xpath $'//div[@id="email_raw"]/pre/text()' - |sed -e 's/&lt;/</g; s/&gt;/>/g; s/&amp;/&/g' >${eid}.eml

exmime=$(which extractmime.py)
if [[ $? -eq 0 ]]; then
    extractmime.py ${eid}.eml
fi

popd
