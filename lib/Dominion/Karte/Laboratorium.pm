use strict;
use utf8;
use warnings;

package Dominion::Karte::Laboratorium;

use base 'Dominion::Kartentyp::Aktion';

use constant Kosten => 5;

sub Aktion {
    my ( $package, $Spieler ) = @_;
    $Spieler->nimmt_auf_die_Hand(2);
    $Spieler->bekommt_Aktionen(1);
}

1;
