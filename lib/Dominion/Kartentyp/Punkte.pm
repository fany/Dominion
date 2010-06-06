use strict;
use utf8;
use warnings;

package Dominion::Kartentyp::Punkte;

use base 'Dominion::Karte';

sub initiale_Auslage($$) {
    my ( $package, $Anzahl_Spieler ) = @_;
    return 12 if $Anzahl_Spieler == 3 || $Anzahl_Spieler == 4;
    return 8 if $Anzahl_Spieler == 2;
    die "Für $Anzahl_Spieler Spieler ist keine Anzahl $package definiert.\n";
}

1;
