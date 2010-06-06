use strict;
use utf8;
use warnings;

package Dominion::Strategie::Katrin;

use base 'Dominion::Spieler';

use Dominion qw(Karte);

sub Kaufphase {
    shift->kauft_erstbeste( map Karte($_), qw(Provinz Gold Herzogtum Silber Kupfer) );
}

__PACKAGE__->meta->make_immutable;

1;
