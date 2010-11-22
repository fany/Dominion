use strict;
use utf8;
use warnings;

package Dominion::Strategie::NurGeld;

use Dominion qw(Karte);
use Any::Moose;

extends 'Dominion::Spieler';

sub Kaufphase {
    shift->kauft_erstbeste( map Karte($_), qw(Provinz Gold Silber) );
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;
