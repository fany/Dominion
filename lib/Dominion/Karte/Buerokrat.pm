use strict;
use utf8;
use warnings;

package Dominion::Karte::Buerokrat;

use base 'Dominion::Kartentyp::Aktion_Angriff';

use Carp qw(croak);
use Dominion qw(Karte Kartenliste);

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler ) = @_;

    $Spieler->Nachziehstapel->add(
        $Spieler->Spiel->Vorrat->sub( Karte('Silber') ) )
      if $Spieler->Spiel->Vorrat->Karten( Karte('Silber') );

    for my $Gegner ( $Spieler->Gegner ) {
        next if $Gegner->wehrt_ab( $package, $Spieler );
        if (
            my ($Karte) =
            sort { $a->Punkte($Gegner) <=> $b->Punkte($Gegner) }
            grep $_->can('Punkte'), $Gegner->Hand->Karten
          )
        {
            print '  '
              . $Gegner->Name
              . ' legt '
              . Kartenliste($Karte)
              . " auf seinen Nachziehstapel.\n"
              if $ENV{DEBUG};
            $Gegner->Nachziehstapel->add( $Gegner->Hand->sub($Karte) );
        }
        else {
            print '  '
              . $Gegner->Name
              . ' hat keine Punktekarte auf der Hand: '
              . Kartenliste( $Gegner->Hand->Karten ) . "\n"
              if $ENV{DEBUG};
        }
    }
}

1;
