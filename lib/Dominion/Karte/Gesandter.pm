use strict;
use utf8;
use warnings;

package Dominion::Karte::Gesandter;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);
use Dominion qw(Kartenliste);

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler ) = @_;

    my @Karten = $Spieler->zieht_vom_Nachziehstapel(5);
    unless (@Karten) {
        print " hat keine nachzuziehenden Karten.\n" if $ENV{DEBUG};
        return;
    }
    my ($Spieler_links) = $Spieler->Gegner;
    my $abzulegende_Karte =
      $Spieler_links->waehlt_abzulegende_Karte_fuer_Spieler_rechts( $Spieler,
        @Karten )
      or
      croak( $Spieler_links->Name . ' muss eine abzulegende Karte wählen.' );
    my $aussortiert;
    my @andere_Karten = grep $_ ne $abzulegende_Karte || $aussortiert++,
      @Karten;
    croak(  $abzulegende_Karte->Name
          . ' in den Karten nicht gefunden: '
          . Kartenliste(@Karten) )
      unless $aussortiert;
    print '  muss ' . $abzulegende_Karte->Name . " ablegen.\n" if $ENV{DEBUG};
    $Spieler->Ablagestapel->add($abzulegende_Karte);
    print '  nimmt ' . Kartenliste(@andere_Karten) . " auf die Hand.\n"
      if $ENV{DEBUG};
    $Spieler->Hand->add(@andere_Karten);
}

1;
