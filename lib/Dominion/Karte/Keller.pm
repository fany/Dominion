use strict;
use utf8;
use warnings;

package Dominion::Karte::Keller;

use base 'Dominion::Kartentyp::Aktion';

use Dominion qw(Kartenliste);

use constant Kosten => 2;

sub Aktion {
    my ( $package, $Spieler, @Karten ) = @_;

    $Spieler->bekommt_Aktionen(1);
    print '  legt ' . Kartenliste(@Karten) . " ab.\n" if $ENV{DEBUG};
    $Spieler->Ablagestapel->add( $Spieler->Hand->sub(@Karten) );
    print ' ' if $ENV{DEBUG};
    $Spieler->bekommt_Karten( scalar @Karten );
}

1;
