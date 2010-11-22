use strict;
use utf8;
use warnings;

package Dominion::Strategie::Katrin;

use Dominion qw(Karte);
use Moose;

extends 'Dominion::Spieler';

sub Kaufphase {
    shift->kauft_erstbeste( map Karte($_), qw(Provinz Gold Herzogtum Silber Kupfer) );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
