use strict;
use utf8;
use warnings;

package Dominion::Spieler;

use Carp qw(croak);
use Dominion qw(Karte Kartenliste);
use Dominion::Stapel;
use List::Util qw(min shuffle sum);
use Moose;
use Moose::Util::TypeConstraints;
use Scalar::Util qw(reftype);

coerce __PACKAGE__, from 'HashRef' => via { __PACKAGE__->new(%$_) };

my @Stapel = qw(Ablagestapel Nachziehstapel);
for my $stapel (@Stapel) {
    has $stapel => (
        isa     => 'Dominion::Stapel',
        is      => 'ro',
        default => sub { Dominion::Stapel->new },
    );
}
for (qw(Auslage Hand)) {
    push @Stapel, $_;
    has $_ => (
        isa     => 'Dominion::Vorrat',
        is      => 'ro',
        default => sub { Dominion::Vorrat->new },
    );
}

has Aktionen_frei => (
    isa     => 'Int',
    is      => 'rw',
    default => 1,
);

has Geld_frei => (
    isa     => 'Int',
    is      => 'rw',
    default => 0,
);

has Kaeufe_frei => (
    isa     => 'Int',
    is      => 'rw',
    default => 1,
);

has Name => (
    isa     => 'Str',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        ( my $Name = ref($self) ) =~ s/.*:://;
        $Name;
    },
);

has Spiel => (
    isa      => 'Dominion::Spiel',
    is       => 'rw',
    weak_ref => 1,
);

has Zuege => (
    isa     => 'Int',
    is      => 'rw',
    default => 0,
);

sub bekommt_Aktionen {
    my ( $self, $Aktionen ) = @_;
    $self->Aktionen_frei( $self->Aktionen_frei + $Aktionen );
}

sub bekommt_Geld {
    my ( $self, $Geld ) = @_;
    $self->Geld_frei( $self->Geld_frei + $Geld );
}

sub bekommt_Kaeufe {
    my ( $self, $Kaeufe ) = @_;
    $self->Kaeufe_frei( $self->Kaeufe_frei + $Kaeufe );
}

sub entsorgt {
    my ( $self, @Karten ) = @_;
    $self->Spiel->Muell->add( $self->Hand->sub(@Karten) );
}

sub kauft {
    my ( $self, @Karten ) = @_;
    if ( ( my $Kaeufe_frei = $self->Kaeufe_frei ) < @Karten ) {
        croak(  $self->Name
              . " hat nur $Kaeufe_frei "
              . ( $Kaeufe_frei == 1 ? 'Kauf' : 'Käufe' )
              . ' zur Verfügung.' );
    }
    my $Kosten = sum( map $_->Kosten, @Karten );
    if ( ( my $Geld = $self->Hand->Geld + $self->Geld_frei ) < $Kosten ) {
        croak(  $self->Name
              . " hat nur $Geld Geld, "
              . Kartenliste(@Karten) . 'koste'
              . ( @Karten == 1 ? 't' : 'n' )
              . " aber $Kosten." );
    }
    else {
        print " hat $Geld Geld und "
          . (
            $self->Kaeufe_frei == 1
            ? 'einen Kauf'
            : $self->Kaeufe_frei . ' Käufe'
          )
          . ".\n"
          if $ENV{DEBUG};
    }
    $self->Kaeufe_frei( $self->Kaeufe_frei - @Karten );
    print ' kauft ' . Kartenliste(@Karten) . ".\n" if $ENV{DEBUG};
    $self->bekommt_Geld( -$Kosten );
    $self->nimmt(@Karten);
}

sub kauft_erstbeste {
    my ( $self, @Karten ) = @_;
    print ' interessiert sich für ' . Kartenliste(@Karten) . ".\n"
      if $ENV{DEBUG} && $ENV{DEBUG} > 1;
    for (@Karten) {
        next
          if $_->Kosten > $self->Hand->Geld + $self->Geld_frei
              || !$self->Spiel->Vorrat->Karten($_);
        $self->kauft($_);
        last unless $self->Kaeufe_frei;
    }
}

sub nimmt {
    my ( $self, @Karten ) = @_;
    $self->Ablagestapel->add( $self->Spiel->Vorrat->sub(@Karten) );
}

sub bekommt_Karten {
    my ( $self, $Karten ) = @_;
    my @gezogene_Karten = $self->zieht_vom_Nachziehstapel($Karten);
    print ' zieht ' . Kartenliste(@gezogene_Karten) . ".\n" if $ENV{DEBUG};
    $self->Hand->add(@gezogene_Karten);
}

sub zieht_vom_Nachziehstapel {
    my ( $self, $Karten ) = @_;
    ( my $_Karten = $self->Nachziehstapel->Karten ) >= $Karten
      and return $self->Nachziehstapel->pop($Karten);
    my @gezogene_Karten = $self->Nachziehstapel->leeren;
    $self->Nachziehstapel->add( shuffle( $self->Ablagestapel->leeren ) );
    @gezogene_Karten,
      $self->Nachziehstapel->pop(
        min( $Karten - $_Karten, scalar $self->Nachziehstapel->Karten ) );
}

sub zieht {
    my $self = shift;
    $self->Zuege( $self->Zuege + 1 );
    print $self->Name . ': '
      . $self->Zuege
      . '. Zug: '
      . Kartenliste( $self->Hand->Karten ) . "\n"
      if $ENV{DEBUG};
    $self->Geld_frei(0);
    $self->Aktionen_frei(1);
    $self->Kaeufe_frei(1);
    $self->Aktionsphase;
    $self->Kaufphase;
    $self->Aufraeumphase;
}

sub Aktionsphase { }

sub spielt_Aktion {
    my ( $self, $Karte, @Argumente ) = @_;
    my $Aktionen_frei = $self->Aktionen_frei
      or croak( $self->Name . ' hat keine Aktion mehr zur Verfügung.' );
    $self->Auslage->add( $self->Hand->sub($Karte) );
    $self->Aktionen_frei( $Aktionen_frei - 1 );
    print ' spielt Aktion ' . Kartenliste($Karte) . ".\n" if $ENV{DEBUG};
    $Karte->Aktion( $self, @Argumente );
}

sub verwendet_Aktionskarten {
    my ( $self, @Regeln ) = @_;
  Aktionskarten: {
        last unless $self->Aktionen_frei;
        my %seen;
        for (@Regeln) {
            my ( $Karte, $sub ) = ref() ? @$_ : $_;
            !$seen{$Karte}++ && $self->Hand->Karten($Karte) or next;
            my @Argumente;
            @Argumente = $sub->() or next if $sub;
            shift @Argumente unless defined $Argumente[0];
            $self->spielt_Aktion( $Karte, @Argumente );
            redo Aktionskarten;    # möglicherweise bessere nachgezogen
        }
    }
}

sub Kaufphase { }

sub Aufraeumphase {
    my $self = shift;
    $self->Ablagestapel->add( $self->Auslage->leeren, $self->Hand->leeren );
    $self->bekommt_Karten(5);
}

sub Gegner {
    my $self    = shift;
    my @Spieler = $self->Spiel->Spieler;
    my $i       = $#Spieler;
    --$i until $Spieler[$i] eq $self;
    @Spieler[ $i + 1 .. $#Spieler, 0 .. $i - 1 ];
}

sub Geld {
    my $self = shift;
    sum( map $self->$_->Geld, @Stapel );
}

sub Karten {
    my $self = shift;
    map $self->$_->Karten(@_), @Stapel;
}

sub Punkte {
    my $self = shift;
    sum( map $self->$_->Punkte($self), @Stapel );
}

sub ist_Gewinner {
    my $self = shift;
    $_ eq $self and return 1 for $self->Spiel->Gewinner;
    '';
}

sub wehrt_ab {
    my ( $self, $Gegner, $Angriffskarte ) = @_;
    return '' if $Gegner eq $self;    # z. B. Spion
    if ( $self->Hand->Karten( Karte('Burggraben') ) ) {
        print '  ' . $self->Name . " wehrt mit Burggraben ab.\n" if $ENV{DEBUG};
        return 1;
    }
    '';
}

# für Gesandten:
sub waehlt_abzulegende_Karte_fuer_Spieler_rechts {
    my ( $self, $Gegner, @Karten ) = @_;
    my ($abzulegende_Karte) = sort {
        ( $b->can('Geld') ? $b->Geld : 0 )
          <=> ( $a->can('Geld') ? $a->Geld : 0 )
          || ( $b->can('Aktion') || 0 ) <=> ( $a->can('Aktion') || 0 )
          || $b->Kosten <=> $a->Kosten
    } @Karten;
    $abzulegende_Karte;
}

# für Angriff mit Miliz:
sub wird_angegriffen_von_Miliz {
    my $self = shift;
    my @Karten_zum_Ablegen;
    for ( $self->Hand->Karten ) {
        last if $self->Hand->Karten <= 3;

        # Muss man je nach Strategie evtl. anders implementieren;
        # man denke z. B. an Umbauten:
        push @Karten_zum_Ablegen, $self->Hand->sub($_)
          unless $_->can('Aktion') || $_->can('Geld');
    }

    if ( $self->Hand->Karten > 3 ) {
        ( undef, undef, undef, my @Karten ) = sort {
            $b->Kosten <=> $a->Kosten
              || ( $b->can('Geld') || 0 ) <=> ( $a->can('Geld') || 0 )
        } $self->Hand->Karten;
        $self->Hand->sub(@Karten);
        push @Karten_zum_Ablegen, @Karten;
    }

    @Karten_zum_Ablegen;
}

__PACKAGE__->meta->make_immutable;

1;
