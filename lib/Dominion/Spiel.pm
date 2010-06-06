use strict;
use utf8;
use warnings;

package Dominion::Spiel;

use Carp qw(croak);
use Dominion qw(Karte);
use Dominion::Vorrat;
use Moose;
use Scalar::Util qw(reftype);

has Spieler => (
    isa        => 'ArrayRef',
    auto_deref => 1,
    is         => 'ro',
    required   => 1,
);

has Vorrat => (
    isa      => 'Dominion::Vorrat',
    coerce   => 1,
    is       => 'rw',
    required => 1,
);

has Muell => (
    isa     => 'Dominion::Stapel',
    is      => 'rw',
    default => sub { Dominion::Stapel->new },
);

around BUILDARGS => sub {
    my ( $orig, $class, %arg ) = @_;

    croak("Ein $class braucht Spieler.\n")
      unless reftype( $arg{Spieler} ) && reftype( $arg{Spieler} ) eq 'ARRAY';

    if ( $arg{Koenigreichkarten} ) {
        $arg{Vorrat} ||= {
            map +( Karte($_) => undef ), qw(
              Kupfer Silber Gold
              Anwesen Herzogtum Provinz
              Fluch
              )
        };
        $arg{Vorrat} = {
            %{ $arg{Vorrat} },
            map +( $_ => undef ),
            @{ delete $arg{Koenigreichkarten} }
        };
    }

    while ( my $Karte = each %{ $arg{Vorrat} } ) {
        $arg{Vorrat}{$Karte} //=
          $Karte->initiale_Auslage( scalar @{ $arg{Spieler} } );
    }

    $class->$orig(%arg);
};

sub BUILD {
    my $self = shift;
    for ( $self->Spieler ) {
        $_->Spiel($self);
        $_->nimmt( ( Karte('Kupfer') ) x 7 );
        $_->nimmt( ( Karte('Anwesen') ) x 3 );
        $_->nimmt_auf_die_Hand(5);
    }
}

sub Gewinner {
    my $self = shift;
    $self->spielen;
    my @Spieler   = $self->Spieler;
    my $maxPunkte = $Spieler[0]->Punkte;
    my $minZuege  = $Spieler[0]->Zuege;
    my @Gewinner  = shift @Spieler;
    for (@Spieler) {
        my $Punkte = $_->Punkte;
        my $Zuege  = $_->Zuege;
        if (   $Punkte > $maxPunkte
            || $Punkte == $maxPunkte && $Zuege < $minZuege )
        {
            @Gewinner  = $_;
            $maxPunkte = $Punkte;
            $minZuege  = $Zuege;
        }
        elsif ( $Punkte == $maxPunkte && $Zuege == $minZuege ) {
            push @Gewinner, $_;
        }
    }
    @Gewinner;
}

sub spielen {
    my $self    = shift;
    my @Spieler = $self->Spieler;
    while ($self->Vorrat->Karten( Karte('Provinz') )
        && $self->Vorrat->leere_Stapel < 3 )
    {
        $Spieler[0]->zieht;
        push @Spieler, shift @Spieler;
    }
}

__PACKAGE__->meta->make_immutable;

1;
