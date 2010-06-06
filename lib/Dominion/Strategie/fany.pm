use strict;
use utf8;
use warnings;

package Dominion::Strategie::fany;

use Dominion qw(Karte);
use Moose;

extends 'Dominion::Spieler';

sub Aktionsphase {
    my $self = shift;

    $self->verwendet_Aktionskarten(
        map( Karte($_), qw(Markt Laboratorium Hexe Schmiede) ),
    );
}

sub Kaufphase {
    my $self = shift;
    $self->kauft_erstbeste(
        map Karte($_),
        'Provinz',
        'Gold',
        $self->Karten( Karte('Hexe') ) >= 2 ? ()          : 'Hexe',
        $self->Karten( Karte('Gold') ) >= 2 ? 'Herzogtum' : (),
        $self->Karten( Karte('Markt') )     ? ()          : 'Markt',
        $self->Karten( Karte('Schmiede'), Karte('Hexe') ) ? () : 'Schmiede',
        'Laboratorium',
        $self->Karten( Karte('Gold') ) >= 2 ? 'Gärten' : (),
        'Silber',
    );
}

__PACKAGE__->meta->make_immutable;

1;
