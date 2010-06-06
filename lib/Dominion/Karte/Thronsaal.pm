use strict;
use utf8;
use warnings;

package Dominion::Karte::Thronsaal;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);
use Dominion qw(Karte Kartenliste);
use Scalar::Util qw(reftype);

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler, $Karte, $Argumente1, $Argumente2 ) = @_;
    croak("$package braucht zwei Array-Referenzen als Argumente.")
      if grep !defined || reftype($_) ne 'ARRAY', $Argumente1, $Argumente2;

    print '  spielt Aktion ' . Kartenliste($Karte) . " doppelt.\n"
      if $ENV{DEBUG};
    $Spieler->Auslage->add( $Spieler->Hand->sub($Karte) );
    $Karte->Aktion( $Spieler, @$Argumente1 );
    $Spieler->Auslage->add( $Spieler->Spiel->Muell->pop(1) )
      if $Karte eq Karte('Festmahl');
    $Karte->Aktion( $Spieler, @$Argumente2 );
}

1;
