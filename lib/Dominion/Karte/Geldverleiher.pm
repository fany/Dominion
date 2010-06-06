
use strict;
use utf8;
use warnings;

package Dominion::Karte::Geldverleiher;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);
use Dominion qw(Karte);

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler ) = @_;
    for ( $Spieler->Hand->Karten ) {
        next unless $_ eq Karte('Kupfer');
        $Spieler->Hand->sub($_);
        $Spieler->bekommt_Geld(3);
        return;
    }
    print '  ' . $Spieler->Name . " hat kein Kupfer auf der Hand.\n"
      if $ENV{DEBUG};
}

1;
