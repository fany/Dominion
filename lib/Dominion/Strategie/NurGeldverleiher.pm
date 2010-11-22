use strict;
use utf8;
use warnings;

package Dominion::Strategie::NurGeldverleiher;

use Dominion qw(Karte);
use Any::Moose;

extends 'Dominion::Spieler';

sub Aktionsphase {
    my $self = shift;
    $self->verwendet_Aktionskarten(
        [
            Karte('Geldverleiher') => sub {
                if   ( $self->Hand->Karten( Karte('Kupfer') ) ) { undef }
                else                                            { () }
              }
        ],
    );
}

sub Kaufphase {
    my $self = shift;
    $self->kauft_erstbeste(
        map Karte($_),
        qw(Provinz Gold),
        $self->Karten( Karte('Geldverleiher') ) ? () : 'Geldverleiher',
        qw(Silber)
    );
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;
