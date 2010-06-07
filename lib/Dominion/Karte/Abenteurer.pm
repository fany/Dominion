use strict;
use utf8;
use warnings;

package Dominion::Karte::Abenteurer;

use base 'Dominion::Kartentyp::Aktion';

use Dominion qw(Kartenliste);

use constant Kosten => 6;

sub Aktion {
    my ( $package, $Spieler ) = @_;

    my ( @Geldkarten, @andere_Karten );
    while ( @Geldkarten < 2
        && ( my $Karte = $Spieler->zieht_vom_Nachziehstapel(1) ) )
    {
        if   ( $Karte->can('Geld') ) { push @Geldkarten,    $Karte }
        else                         { push @andere_Karten, $Karte }
    }
    print '  nimmt ' . Kartenliste(@Geldkarten) . " auf die Hand.\n"
      if $ENV{DEBUG};
    $Spieler->Hand->add(@Geldkarten);
    print '  legt ' . Kartenliste(@andere_Karten) . " ab.\n" if $ENV{DEBUG};
    $Spieler->Ablagestapel->add(@andere_Karten);
}

1;
