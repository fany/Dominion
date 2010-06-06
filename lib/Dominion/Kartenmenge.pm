use strict;
use utf8;
use warnings;

package Dominion::Kartenmenge;

use List::Util qw(sum);
use Moose;

sub Geld {
    my $self = shift;
    sum( 0, map $_->Geld, grep $_->can('Geld'), $self->Karten );
}

sub Punkte {
    my ( $self, $Spieler ) = @_;
    sum( 0, map $_->Punkte($Spieler), grep $_->can('Punkte'), $self->Karten );
}

sub unterschiedliche_Karten {
    my $self = shift;
    my %seen;
    grep !$seen{$_}++, $self->Karten(@_);
}

__PACKAGE__->meta->make_immutable;

1;
