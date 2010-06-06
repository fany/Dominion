use strict;
use utf8;
use warnings;

package Dominion::Karte::Hexe;

use base 'Dominion::Kartentyp::Aktion_Angriff';

use Carp qw(croak);
use Dominion qw(Karte);

use constant Kosten => 5;

sub Aktion {
    my ( $package, $Spieler ) = @_;

    $Spieler->bekommt_Karten(2);

    for my $Gegner ( $Spieler->Gegner ) {
        next if $Gegner->wehrt_ab( $package, $Spieler );
        if ( $Gegner->Spiel->Vorrat->Karten( Karte('Fluch') ) ) {
            print '  ' . $Gegner->Name . " nimmt eine Fluch-Karte.\n"
              if $ENV{DEBUG};
            $Gegner->nimmt( Karte('Fluch') );
        }
        else {
            print "  Es sind keine Fluchkarten mehr im Vorrat.\n"
              if $ENV{DEBUG};
        }
    }
}

1;
