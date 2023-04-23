#!/usr/bin/perl -w

# legge il file in ingresso.
# deve trovare la riga con <td><font face="Arial ...
# e continuare fino alla chiusura del font, </font>
my $stato;
$stato=0;
while (<STDIN>) {
 if (( m|</font></td>| ) && ($stato==1)) {
   $stato=0;
   print;
   last;
 }
 if ( $stato== 1 ) { print; }
 if (( /<td><font face="Arial/ ) && ($stato==0)) {
   print;
   last if (m|</font></td>|);
   $stato=1;
 }
}
