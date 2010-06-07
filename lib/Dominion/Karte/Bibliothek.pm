use strict;
use utf8;
use warnings;

package Dominion::Karte::Bibliothek;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);
use Dominion qw(Kartenliste);
use Scalar::Util qw(reftype);

use constant Kosten => 5;

sub Aktion {
    my ( $package, $Spieler, $entscheide_ob_Aktionskarte_ablegen ) = @_;
    croak("$package braucht eine Sub-Routine als Argument.")
      if !defined $entscheide_ob_Aktionskarte_ablegen
          || reftype($entscheide_ob_Aktionskarte_ablegen) ne 'CODE';

    my @abzulegende_Karten;
    while ( $Spieler->Hand->Karten < 7
        && ( my ($Karte) = $Spieler->zieht_vom_Nachziehstapel(1) ) )
    {
        if (   !$Karte->can('Aktion')
            || !$entscheide_ob_Aktionskarte_ablegen->($Karte) )
        {
            print '  nimmt ' . $Karte->Name . " auf die Hand.\n" if $ENV{DEBUG};
            $Spieler->Hand->add($Karte);
        }
        else { push @abzulegende_Karten, $Karte }
    }
    print '  legt ' . Kartenliste(@abzulegende_Karten) . " ab.\n"
      if $ENV{DEBUG};
    $Spieler->Ablagestapel->add(@abzulegende_Karten);
}

1;
