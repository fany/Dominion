use strict;
use utf8;
use warnings;

package Dominion::Karte::Gaerten;

use base 'Dominion::Kartentyp::Punkte';

use constant Kosten => 4;

sub Punkte {
    my ( $package, $Spieler ) = @_;
    int( $Spieler->Karten / 10 );
}

1;
