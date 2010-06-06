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
        map( Karte($_), qw(Jahrmarkt Laboratorium Markt Dorf) ),
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
            Karte('Geldverleiher') => sub {
                if   ( $self->Hand->Karten( Karte('Kupfer') ) ) { undef }
                else                                            { () }
              }
        ],
        [
            Karte('Festmahl') => sub {
                $self->finde_beste_Karte( sub { shift->Kosten <= 5 } );
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
