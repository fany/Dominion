use strict;
use utf8;
use warnings;

package Dominion::Karte::Laboratorium;

use base 'Dominion::Kartentyp::Aktion';

use constant Kosten => 5;

sub Aktion {
    my ( $package, $Spieler ) = @_;
    $Spieler->bekommt_Karten(2);
    $Spieler->bekommt_Aktionen(1);
}

1;
