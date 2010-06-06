use strict;
use utf8;
use warnings;

package Dominion::Karte::Spion;

use base 'Dominion::Kartentyp::Aktion_Angriff';

use Carp qw(croak);
use Dominion qw(Kartenliste);
use Scalar::Util qw(reftype);

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler, $entscheide_ob_ablegen ) = @_;
    croak("$package braucht eine Sub-Routine als Argument.")
      if !defined $entscheide_ob_ablegen
          || reftype($entscheide_ob_ablegen) ne 'CODE';

    $Spieler->bekommt_Karten(1);
    $Spieler->bekommt_Aktionen(1);

    for my $Gegner ( $Spieler->Spiel->Spieler ) {
        unless ( my ($Karte) = $Gegner->zieht_vom_Nachziehstapel(1) ) {
            print '  ' . $Gegner->Name . " hat keine Karten zum Nachziehen.\n"
              if $ENV{DEBUG};
        }
        elsif ( $entscheide_ob_ablegen->( $Gegner, $Karte ) ) {
            print '  '
              . $Gegner->Name
              . ' muss '
              . Kartenliste($Karte)
              . " ablegen.\n"
              if $ENV{DEBUG};
            $Gegner->Ablagestapel->add($Karte);
        }
        else {
            print '  '
              . $Gegner->Name
              . ' muss '
              . Kartenliste($Karte)
              . " zurück auf den Nachziehstapel legen.\n"
              if $ENV{DEBUG};
            $Gegner->Nachziehstapel->add($Karte);
        }
    }
}

1;
