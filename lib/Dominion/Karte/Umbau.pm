use strict;
use utf8;
use warnings;

package Dominion::Karte::Umbau;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler, $Karte_alt, $Karte_neu ) = @_;
    if ( grep( !$_ || !$_->isa('Dominion::Karte'), $Karte_alt, $Karte_neu )
        && ( my $Karten_auf_Hand = $Spieler->Hand_Karten ) )
    {
        croak(  "$package: "
              . $Spieler->Name
              . " hat $Karten_auf_Hand auf der Hand, aber keine zum Umtausch angegeben."
        );
    }
    croak(  "$package: Die neue Karte ($Karte_neu) darf maximal (2)"
          . " mehr kosten als die zu entsorgende ($Karte_alt)." )
      if $Karte_neu->Kosten - $Karte_alt->Kosten > 2;

    print '  entsorgt '
      . $Karte_alt->Name
      . ' und nimmt dafür '
      . $Karte_neu->Name . ".\n"
      if $ENV{DEBUG};
    $Spieler->entsorgt($Karte_alt);
    $Spieler->nimmt($Karte_neu);
}

1;
