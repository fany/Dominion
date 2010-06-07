use strict;
use utf8;
use warnings;

package Dominion::Karte::Holzfaeller;

use base 'Dominion::Kartentyp::Aktion';

use constant { Kosten => 3, Name => 'Holzfäller' };

sub Aktion {
    my ( $package, $Spieler ) = @_;
    $Spieler->bekommt_Kaeufe(1);
    $Spieler->bekommt_Geld(2);
}

1;
