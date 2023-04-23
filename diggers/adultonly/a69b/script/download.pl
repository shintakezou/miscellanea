#! /usr/bin/perl

# download from a*69 site.
# NEEDS curl and, alas, a *n*x environment...

# Real url is not given sorry, you must do your own homework

# TODO: use LWP instead of curl command

my %addrlist;


my $fcookie = 'fcookie';
my $scookie = 'scookie';
my $purl = "curl -A Mozilla/5.0 -L";

while(<STDIN>)
{
    chomp;
    foreach my $el ( split /;/ )
    {
      #http://img.XXXXXXXXX.XX/XXXXXXX/XXXXXXXXXXXXX
      # this "greps" and catch the addresses of the images.
      if ( $el =~ m|"(http://img\.XXXXXXXXX\.XX/XXXXXXX/XXXXXXXXXXXXX/.*?)"| )
      {
         my @pezzi = split('/', $1);
         if ( ! defined( $addrlist{$pezzi[5]} ) )
         {
             $addrlist{$pezzi[5]} = [];
         } else {
             push @{$addrlist{$pezzi[5]}}, $1;
         }
      }
    }
}

foreach my $esib ( keys %addrlist )
{
   if ( -d $esib )
   {
       print STDERR "$esib\t\talready done\n";
       next;
   } else {
     printf "*********** DOWNLOADING %25s *************\n", $esib;
     if ( mkdir($esib) )
     {
         foreach my $addr ( @{$addrlist{$esib}} )
         {
                 zurl($addr, $esib);
         }
     } else {
       print STDERR "ERROR creating dir $esib\n";
     }
   }
}


sub zurl
{
     my ( $indirizzo, $cartella ) = @_;
     my @arti = split '/', $indirizzo;
     my $fname = $arti[6];
     if ( -e $fcookie )
     {
         `$purl -b $fcookie -c $scookie "$indirizzo" -o "$cartella/$fname"`;
         if ( -e $scookie )
         {
              # TODO: do not use mv ...
              `mv -f $scookie $fcookie`;
         }
     } else {
         `$purl -c $fcookie "$indirizzo" -o "$cartella/$fname"`;
     }
}

exit 0;
