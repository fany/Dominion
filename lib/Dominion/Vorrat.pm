use strict;
use utf8;
use warnings;

package Dominion::Vorrat;

use Moose;

extends 'Dominion::Kartenmenge';

use Carp qw(croak);
use Moose::Util::TypeConstraints;
use Scalar::Util qw(reftype);

coerce __PACKAGE__,
  (
    from
      ArrayRef => via { __PACKAGE__->new($_) },
    from HashRef => via { __PACKAGE__->new($_) },
  );

around BUILDARGS => sub {
    my $orig    = shift;
    my $class   = shift;
    my $reftype = reftype( my $ref = shift );
    croak(  "Ein $class kann nur durch eine Array- "
          . 'oder eine Hash-Referenz erzeugt werden.' )
      if @_ || defined $reftype && $reftype ne 'ARRAY' && $reftype ne 'HASH';
    unless ( defined $reftype ) { $class->$orig }
    elsif ( $reftype eq 'ARRAY' ) {
        my %Karten;
        ++$Karten{$_} for @$ref;
        $class->$orig( _Karten => \%Karten );
    }
    else { $class->$orig( _Karten => $ref ) }
};

has _Karten => (
    is      => 'ro',
    isa     => 'HashRef[Int]',
    default => sub { {} },
);

sub Karten {
    my $self = shift;
    map +($_) x ( $self->_Karten->{$_} // 0 ),
      @_ ? @_ : keys %{ $self->_Karten };
}

sub unterschiedliche_Karten {
    my $self = shift;
    grep $self->_Karten->{$_}, @_ ? @_ : keys %{ $self->_Karten };
}

sub add {
    my ( $self, @Karten ) = @_;
    ++$self->_Karten->{$_} for @Karten;
    @Karten;
}

sub clone {
    my $self = shift;
    $self->new( \%{ $self->_Karten } );
}

sub leeren {
    my $self   = shift;
    my @Karten = $self->Karten;
    %{ $self->_Karten } = ();
    @Karten;
}

sub leere_Stapel {
    my $self         = shift;
    my $leere_Stapel = 0;
    $_ == 0 and ++$leere_Stapel for values %{ $self->_Karten };
    $leere_Stapel;
}

sub sub {
    my ( $self, @Karten ) = @_;
    $self->_Karten->{$_}--
      or croak( ref($self) . ' enthält keine ' . $_->Name . '.' )
      for @Karten;
    @Karten;
}

__PACKAGE__->meta->make_immutable;

1;
