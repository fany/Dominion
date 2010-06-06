use strict;
use utf8;
use warnings;

package Dominion::Karte::Mine;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);
use Dominion qw(Kartenliste);

use constant Kosten => 5;

sub Aktion {
    my ( $package, $Spieler, $Karte_alt, $Karte_neu ) = @_;

    if ( grep !$_ || !$_->isa('Dominion::Karte'), $Karte_alt, $Karte_neu ) {
        ( my @Geldkarten = grep $_->can('Geld'), $Spieler->Hand->Karten )
          or return;
        croak(  "$package: "
              . $Spieler->Name . ' hat '
              . Kartenliste(@Geldkarten)
              . ', aber keine zum Umtausch angegeben.' );
    }
    croak("$package: Die neue Karte muss eine Geldkarte sein.")
      unless $Karte_neu->can('Geld');
    croak(  "$package: Die neue Karte ($Karte_neu) darf maximal (3)"
          . " mehr kosten als die zu entsorgende ($Karte_alt)." )
      if $Karte_neu->Kosten - $Karte_alt->Kosten > 3;

    print '  entsorgt '
      . $Karte_alt->Name
      . ' und nimmt dafür '
      . $Karte_neu->Name
      . " auf die Hand.\n"
      if $ENV{DEBUG};
    $Spieler->entsorgt($Karte_alt);
    $Spieler->Hand->add( $Spieler->Spiel->Vorrat->sub($Karte_neu) );
}

1;
