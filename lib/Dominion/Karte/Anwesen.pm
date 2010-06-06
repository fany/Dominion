use strict;
use utf8;
use warnings;

package Dominion::Karte::Anwesen;

use Moose;
use base 'Dominion::Kartentyp::Punkte';

use constant { Kosten => 2, Punkte => 1 };

around initiale_Auslage => sub {
    my ( $orig, $self, $Spieler ) = @_;
    $Spieler * 3 + $self->$orig($Spieler);
};

__PACKAGE__->meta->make_immutable;

1;
