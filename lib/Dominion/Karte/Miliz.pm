use strict;
use utf8;
use warnings;

package Dominion::Karte::Miliz;

use base 'Dominion::Kartentyp::Aktion_Angriff';

use Carp qw(croak);
use Dominion qw(Kartenliste);

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler ) = @_;

    $Spieler->bekommt_Geld(2);

    for my $Gegner ( $Spieler->Gegner ) {
        next if $Gegner->wehrt_ab( $package, $Spieler );

        if ( my @Karten_zum_Ablegen =
            $Gegner->wird_angegriffen_von_Miliz($Spieler) )
        {
            print '  '
              . $Gegner->Name
              . ' legt '
              . Kartenliste(@Karten_zum_Ablegen)
              . " ab.\n"
              if $ENV{DEBUG};
            $Gegner->Ablagestapel->add(@Karten_zum_Ablegen);
        }
        croak(  $Gegner->Name
              . ' hat nach Angriff mit Miliz immer noch '
              . $Gegner->Hand->Karten
              . ' Karten auf der Hand.' )
          if $Gegner->Hand->Karten > 3;
        print '  '
          . $Gegner->Name
          . ' behält '
          . Kartenliste( $Gegner->Hand->Karten ) . ".\n"
          if $ENV{DEBUG};
    }
}

1;
