use strict;
use utf8;
use warnings;

package Dominion::Karte::Schmiede;

use base 'Dominion::Kartentyp::Aktion';

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler ) = @_;
    $Spieler->bekommt_Karten(3);
}

1;
