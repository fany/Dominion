use strict;
use utf8;
use warnings;

package Dominion::TestSpiel;

use Dominion qw(Karte);
use List::Util qw(min);
use Moose;

extends 'Dominion::Spiel';

=cut

Bei einem Testspiel kommt jeder Spieler gleich oft zum Zug,
und innerhalb jeder Runde haben alle Spieler denselben Kartenvorrat.

=cut

sub spielen {
    my $self    = shift;
    my @Spieler = $self->Spieler;
    while ($self->Vorrat->Karten( Karte('Provinz') )
        && $self->Vorrat->leere_Stapel < 3 )
    {
        my $Vorrat_diese_Runde    = $self->Vorrat;
        my $Vorrat_naechste_Runde = $self->Vorrat->clone;
        for (@Spieler) {
            $self->Vorrat( $Vorrat_diese_Runde->clone );
            $_->zieht;
            for ( $Vorrat_naechste_Runde->unterschiedliche_Karten ) {
                my $Differenz =
                  $Vorrat_diese_Runde->Karten($_) - $self->Vorrat->Karten($_)
                  or next;
                $Vorrat_naechste_Runde->sub(
                    ($_) x min(
                        scalar $Vorrat_naechste_Runde->Karten($_), $Differenz
                    )
                );
            }
        }
        $self->Vorrat($Vorrat_naechste_Runde);
    }
}

__PACKAGE__->meta->make_immutable;

1;
