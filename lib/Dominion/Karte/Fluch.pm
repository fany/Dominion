use strict;
use utf8;
use warnings;

package Dominion::Karte::Fluch;

use base 'Dominion::Karte';

use constant { Kosten => 0, Punkte => -1 };

sub initiale_Auslage($$) {
    my ( $package, $Anzahl_Spieler ) = @_;
    return 30 if $Anzahl_Spieler == 4;
    return 20 if $Anzahl_Spieler == 3;
    return 10 if $Anzahl_Spieler == 2;
    die "Für $Anzahl_Spieler Spieler ist keine Anzahl $package definiert.\n";
}

1
