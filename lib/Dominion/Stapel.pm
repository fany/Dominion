use strict;
use utf8;
use warnings;

package Dominion::Stapel;

use Carp qw(croak);
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';

extends 'Dominion::Kartenmenge';

coerce __PACKAGE__, (
    from
      ArrayRef => via { __PACKAGE__->new(@$_) },
    from HashRef => via {
        my $_Karten;
        __PACKAGE__->new( map +($_) x $_Karten->{$_}, keys %$_Karten );
    },
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    $class->$orig( _Karten => [@_] );
};

has _Karten => (
    isa      => 'ArrayRef[Dominion::Karte]',
    is       => 'ro',
    required => 1,
    default  => sub { [] },
);

sub Karten {
    my $self = shift;
    return @{ $self->_Karten } unless @_;
    my %Karten;
    @Karten{@_} = undef;
    grep exists $Karten{$_}, @{ $self->_Karten };
}

sub add {
    my ( $self, @Karten ) = @_;
    push @{ $self->_Karten }, @Karten;
}

sub leeren {
    my $self   = shift;
    my @Karten = reverse $self->Karten;
    @{ $self->_Karten } = ();
    @Karten;
}

sub pop {
    my ( $self, $Karten ) = @_;
    croak(
            ref($self)
          . ' enthält nur '
          . $self->Karten
          . " statt $Karten Karten." )
      if $self->Karten < $Karten;
    if (wantarray) { reverse splice @{ $self->_Karten }, -$Karten }
    elsif ( $Karten != 1 ) {
        croak( ref($self) . "->pop($Karten) in skalarem Kontext aufgerufen." );
    }
    else { pop @{ $self->_Karten } }
}

__PACKAGE__->meta->make_immutable;
no Any::Moose;

1;
