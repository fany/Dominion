use strict;
use utf8;
use warnings;

package Dominion::Karte::Ratsversammlung;

use base 'Dominion::Kartentyp::Aktion';

use constant Kosten => 5;

sub Aktion {
    my ( $package, $Spieler ) = @_;
    print ' ' if $ENV{DEBUG};
    $Spieler->bekommt_Karten(4);
    $Spieler->bekommt_Kaeufe(1);
    for my $Gegner ( $Spieler->Gegner ) {
        print '  ' . $Gegner->Name if $ENV{DEBUG};
        $Gegner->bekommt_Karten(1);
    }
}

1;
