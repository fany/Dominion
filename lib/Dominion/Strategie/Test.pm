use strict;
use utf8;
use warnings;

package Dominion::Strategie::Test;

use Dominion qw(Karte);
use Moose;

extends 'Dominion::Spieler';

sub Aktionsphase {
    my $self = shift;
    $self->verwendet_Aktionskarten(
        [
            Karte('Thronsaal') => sub {
                my ($Aktionskarte) =
                  sort { $b->Kosten <=> $a->Kosten }
                  grep $_->can('Aktion')

              # TODO: Diese Karten im Zusammenhang mit Thronsaal implementieren:
                  && $_ ne Karte('Thronsaal')
                  && $_ ne Karte('Spion')
                  && $_ ne Karte('Mine')
                  && $_ ne Karte('Dieb')
                  && $_ ne Karte('Festmahl')
                  && $_ ne Karte('Umbau')
                  && $_ ne Karte('Geldverleiher')
                  && $_ ne Karte('Werkstatt')
                  && $_ ne Karte('Kanzler')
                  && $_ ne Karte('Kapelle'), $self->Hand->Karten
                  or return;
                $Aktionskarte, [], [];
            },
        ],
        map( Karte($_), qw(Jahrmarkt Laboratorium Markt Dorf) ),
        [
            Karte('Spion') => sub {
                sub {
                    my ( $Gegner, $Karte ) = @_;
                    $Karte->can('Aktion')
                      || $Karte->can('Geld') xor $Gegner eq $self;
                  }
              }
        ],
        [
            Karte('Mine') => sub {
                my ($Karte_alt) =
                  sort { $a->Kosten <=> $b->Kosten } grep $_->can('Geld'),
                  $self->Hand->Karten
                  or return;
                my ($Karte_neu) = $self->finde_beste_Karte(
                    sub {
                        my $Karte = shift;
                        $Karte->can('Geld')
                          && $Karte->Kosten - $Karte_alt->Kosten > 0
                          && $Karte->Kosten - $Karte_alt->Kosten <= 3;
                    }
                ) or return;
                $Karte_alt => $Karte_neu;
              }
        ],
        [
            Karte('Dieb') => sub {
                sub {
                    my $Spieler = shift;
                    ( sort { $b->Geld <=> $a->Geld } @_ )[0];
                  }, sub {
                    grep $_->Geld > $self->Geld / $self->Karten,
                      sort { $b->Geld <=> $a->Geld } @_;
                  }
            },
        ],
        [
            Karte('Festmahl') => sub {
                $self->finde_beste_Karte( sub { shift->Kosten <= 5 } );
              }
        ],
        [
            Karte('Umbau') => sub {
                my $i = 0;
                my %Rang;
                $Rang{$_} = ++$i for $self->beste_Karten;
                my ( $seen_Umbau, $alte_Karte, $beste_neue_Karte,
                    $maximale_Differenz );
                for ( $self->Hand->Karten ) {
                    next if $_ eq Karte('Umbau') && !$seen_Umbau++;
                    unless ( exists $Rang{$_} ) {    # Fluch o. Ä.
                        $alte_Karte = $_;
                    }
                    my $Kosten_alte_Karte = $_->Kosten;
                    my $neue_Karte        = $self->finde_beste_Karte(
                        sub { shift->Kosten - $Kosten_alte_Karte <= 2 } );
                    defined $maximale_Differenz
                      && ( my $Differenz =
                        ( $Rang{$_} // $i << 1 ) - $Rang{$neue_Karte} ) <=
                      $maximale_Differenz
                      and next;
                    $maximale_Differenz = $Differenz;
                    $alte_Karte         = $_;
                    $beste_neue_Karte   = $neue_Karte;
                }
                $alte_Karte => $beste_neue_Karte;
            },
        ],
        [
            Karte('Geldverleiher') => sub {
                if   ( $self->Hand->Karten( Karte('Kupfer') ) ) { undef }
                else                                            { () }
              }
        ],
        [
            Karte('Werkstatt') => sub {
                $self->finde_beste_Karte( sub { shift->Kosten <= 4 } );
              }
        ],
        [ Karte('Kanzler') => sub { 1 } ],
        [
            Karte('Kapelle') => sub {
                grep !$_->Kosten && !$_->can('Geld'), $self->Hand->Karten;
            },
        ],
        sort { $b->Kosten <=> $a->Kosten }
          grep $_->can('Aktion'),
        $self->Hand->Karten
    );
}

sub Kaufphase {
    my $self = shift;
    $self->kauft_erstbeste( $self->beste_Karten );
}

sub beste_Karten {
    my $self = shift;
    sort {
             $b->Kosten <=> $a->Kosten
          || $self->Karten($a) <=> $self->Karten($b)
          || ( $b->can('Geld') ? $b->Geld : 0 )
          <=> ( $a->can('Geld') ? $a->Geld : 0 )
      } grep !$_->can('Punkte')
      || $_->Punkte($self) > 0, $self->Spiel->Vorrat->unterschiedliche_Karten;
}

sub finde_beste_Karte {
    my ( $self, @Bedingungen ) = @_;
  Karte: for my $Karte ( $self->beste_Karten ) {
        $_->($Karte) or next Karte for @Bedingungen;
        return $Karte;
    }
    ();
}

__PACKAGE__->meta->make_immutable;

1;
