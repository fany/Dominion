use strict;
use utf8;
use warnings;

package Dominion::Karte::Kapelle;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);

use constant Kosten => 2;

sub Aktion {
    my ( $package, $Spieler, @Karten ) = @_;
    croak("$package kann maximal vier Karten entsorgen.") if @Karten > 4;
    $Spieler->entsorgt(@Karten);
}

1;
