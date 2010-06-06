use strict;
use utf8;
use warnings;

package Dominion::Karte::Werkstatt;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);

use constant Kosten => 3;

sub Aktion {
    my ( $package, $Spieler, $Karte ) = @_;
    croak("$package braucht eine Karte als Argument.")
      unless defined $Karte && $Karte->isa('Dominion::Karte');
    croak("$package erlaubt nur das Nehmen von Karten, die maximal 4 kosten.")
      if $Karte->Kosten > 4;
    $Spieler->nimmt($Karte);
}

1;
