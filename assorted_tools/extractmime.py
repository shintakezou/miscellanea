#! /usr/bin/python

import email
import mimetypes
import sys
import os

fp = open(sys.argv[1])
msg = email.message_from_file(fp)
fp.close()


counter = 1
for part in msg.walk():
    if part.get_content_maintype() == 'multipart':
        continue
    fn = part.get_filename()
    if not fn:
        ext = mimetypes.guess_extension(part.get_content_type())
        if not ext:
            ext = ".bin"
        fn = 'part-%03d%s' % (counter, ext)
    counter += 1
    fp=open(os.path.join('.', fn), 'wb')
    fp.write(part.get_payload(decode=True))
    fp.close()

