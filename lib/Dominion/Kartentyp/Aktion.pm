use strict;
use utf8;
use warnings;

package Dominion::Kartentyp::Aktion;

use base 'Dominion::Karte';

use Carp qw(croak);

use constant initiale_Auslage => 10;

sub Aktion {
    my ( $package, $Spieler ) = @_;
    croak("Für $package ist noch keine Aktion definiert.");
}

1;
