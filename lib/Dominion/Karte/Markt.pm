use strict;
use utf8;
use warnings;

package Dominion::Karte::Markt;

use base 'Dominion::Kartentyp::Aktion';

use constant Kosten => 5;

sub Aktion {
    my ( $package, $Spieler ) = @_;
    $Spieler->bekommt_Karten(1);
    $Spieler->bekommt_Aktionen(1);
    $Spieler->bekommt_Kaeufe(1);
    $Spieler->bekommt_Geld(1);
}

1;
