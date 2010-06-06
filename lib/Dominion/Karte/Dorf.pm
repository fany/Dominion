use strict;
use utf8;
use warnings;

package Dominion::Karte::Dorf;

use base 'Dominion::Kartentyp::Aktion';

use constant Kosten => 3;

sub Aktion {
    my ( $package, $Spieler ) = @_;
    $Spieler->bekommt_Karten(1);
    $Spieler->bekommt_Aktionen(2);
}

1;
