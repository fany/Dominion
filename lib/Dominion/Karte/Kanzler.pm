use strict;
use utf8;
use warnings;

package Dominion::Karte::Kanzler;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);

use constant Kosten => 3;

sub Aktion {
    my ( $package, $Spieler, $ablegen ) = @_;
    croak("$package braucht einen Wahrheitswert als Argument.")
      unless defined $ablegen;
    $Spieler->bekommt_Geld(2);
    $Spieler->Ablagestapel->add( $Spieler->Nachziehstapel->leeren ) if $ablegen;
}

1;
