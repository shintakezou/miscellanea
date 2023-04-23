#! /usr/bin/perl

# italian version

use strict;
use Date::Simple ('date', 'leap_year');

my @giorni = ('Dom', 
              'Lun', 
              'Mar', 
              'Mer', 
              'Gio', 
              'Ven', 
              'Sab');

my @nwd = ('Req', 'Pri', 'Sec', 'Ter', 'Lud');

my @mesi = ('',
            'Gennaio',
            'Febbraio',
            'Marzo', 
            'Aprile', 
            'Maggio', 
            'Giugno', 
            'Luglio', 
            'Agosto', 
            'Settembre', 
            'Ottobre', 
            'Novembre', 
            'Dicembre');

my @nmes = ('',
            'Primaio',
            'Secondaio',
            'Terzaio', 
            'Quartaio', 
            'Quintaio', 
            'Sestaio', 
            'Settimaio', 
            'Ottavaio', 
            'Nonaio', 
            'Deciano', 
            'Undiciano', 
            'Dodeciano');

my @specday;


my $nday = 1;
my $nmonth = 1;
my $nweekday = 0;

# ===========================
my $d = date('2016-01-01');
# ===========================


my $isleap = leap_year($d->year);
my $destday = $isleap ? 366 : 365;

push @specday, "Capodanno";

sub newcal_succ
{
    my ($leap, $sd, $d, $m, $w) = @_;

    if ($leap && $m == 12 && $d == 30) {
        push @$sd, "Bisestile";
    } elsif ($m == 2 && $d == 30) {
        push @$sd, "Secondo speciale";
    } elsif ($m == 5 && $d == 30) {
        push @$sd, "Terzo speciale";
    } elsif ($m == 8 && $d == 30) {
        push @$sd, "Quarto speciale";
    } elsif ($m == 11 && $d == 30) {
        push @$sd, "Quinto speciale";
    }
    
    $d += 1;
    if ($d > 30) {
        $d = 1;
        $m += 1;
    }

    $w = ($d-1) % 5;

    return ($d, $m, $w);
}

for(my $i = 1; $i <= $destday; $i++, $d += 1) {
    my $regolare = sprintf("%4d %3s %14s", 
                           $d->day,
                           $giorni[$d->day_of_week],
                           $mesi[$d->month]);
    my $nc = "";
    if (@specday > 0) {
        my $s = pop @specday;
        $nc = sprintf("     %-18s", $s);
    } else {
        $nc = sprintf("%4d %3s %14s",
                      $nday,
                      $nwd[$nweekday],
                      $nmes[$nmonth]);
        ($nday, $nmonth, $nweekday) = newcal_succ($isleap, \@specday,
                                                  $nday, 
                                                  $nmonth,
                                                  $nweekday);
    }
    print "$i\t$regolare\t$nc\n";
}


exit 0;

