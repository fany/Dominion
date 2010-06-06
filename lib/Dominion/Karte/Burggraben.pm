use strict;
use utf8;
use warnings;

package Dominion::Karte::Burggraben;

use base 'Dominion::Kartentyp::Aktion_Reaktion';

use constant Kosten => 2;

sub Aktion {
    my ( $package, $Spieler ) = @_;
    $Spieler->nimmt_auf_die_Hand(2);
}

1;
