use strict;
use utf8;
use warnings;

package Dominion::Karte::Festmahl;

use base 'Dominion::Kartentyp::Aktion';

use Carp qw(croak);

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler, $Karte ) = @_;
    croak("$package braucht eine Karte als Argument.")
      if !defined $Karte || !$Karte->isa('Dominion::Karte');
    croak("$package: Die neue Karte darf maximal (5) kosten.")
      if $Karte->Kosten > 5;

    $Spieler->Spiel->Muell->add( $Spieler->Auslage->sub($package) );

    print '  nimmt ' . $Karte->Name . ".\n" if $ENV{DEBUG};
    $Spieler->nimmt($Karte);
}

1;
