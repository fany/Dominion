use strict;
use utf8;
use warnings;

package Dominion::Strategie::NurGeld;

use base 'Dominion::Spieler';

use Dominion qw(Karte);

sub Kaufphase {
    shift->kauft_erstbeste( map Karte($_), qw(Provinz Gold Silber) );
}

__PACKAGE__->meta->make_immutable;

1;
