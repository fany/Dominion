use strict;
use utf8;
use warnings;

package Dominion::Karte::Mine;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);

use constant Kosten => 5;

sub Aktion {
    my ( $package, $Spieler, $Karte_alt, $Karte_neu ) = @_;
    croak("$package braucht zwei Karten als Argumente.")
      if grep !$_ || !$_->isa('Dominion::Karte'), $Karte_alt, $Karte_neu;
    croak("$package: Die neue Karte muss eine Geldkarte sein.")
      unless $Karte_neu->can('Geld');
    croak(
        "$package: Die neue Karte ($Karte_neu) darf maximal (3)"
          . " mehr kosten als die zu entsorgende ($Karte_alt)." )
      if $Karte_neu->Kosten - $Karte_alt->Kosten > 3;

    $Spieler->entsorgt($Karte_alt);

    print ' nimmt ' . $Karte_neu->Name . " auf die Hand.\n"
      if $ENV{DEBUG};
    $Spieler->Hand->add( $Spieler->Spiel->Vorrat->sub($Karte_neu) );
}

1;
