use strict;
use utf8;
use warnings;

package Dominion::Strategie::fany;

use base 'Dominion::Spieler';

use Dominion qw(Karte);

sub Aktionsphase {
    my $self = shift;

    $self->verwendet_Aktionskarten(
        map( Karte($_), qw(Markt Laboratorium Hexe Schmiede) ),
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
        'Provinz',
        'Gold',
        $self->Karten( Karte('Hexe') ) >= 2 ? ()          : 'Hexe',
        $self->Karten( Karte('Gold') ) >= 2 ? 'Herzogtum' : (),
        $self->Karten( Karte('Markt') )     ? ()          : 'Markt',
        $self->Karten( Karte('Schmiede'), Karte('Hexe') ) ? () : 'Schmiede',
        # $self->Karten( Karte('Geldverleiher') ) ? () : 'Geldverleiher',
        'Laboratorium',
        $self->Karten( Karte('Gold') ) >= 2 ? 'Gärten' : (),
        'Silber',
    );
}

__PACKAGE__->meta->make_immutable;

1;
