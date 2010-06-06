use strict;
use utf8;
use warnings;

package Dominion::Karte::Dieb;

use base 'Dominion::Kartentyp::Aktion_Angriff';

use Carp qw(croak);
use Dominion qw(Kartenliste);
use List::Util qw(min);

use constant Kosten => 4;

sub Aktion {
    my ( $package, $Spieler, $entscheide_welche_entsorgen,
        $entscheide_welche_nehmen )
      = @_;

    my @entsorgte_Geldkarten;
    for my $Gegner ( $Spieler->Gegner ) {
        next if $Gegner->wehrt_ab( $package, $Spieler );

        unless ( $Gegner->Nachziehstapel->Karten ) {
            print '  '
              . $Gegner->Name
              . " hat keine Karten auf dem Nachziehstapel.\n"
              if $ENV{DEBUG};
            next;
        }

        my @Geldkarten;
        {
            my @aufgedeckte_Karten = $Gegner->Nachziehstapel->pop(
                min( scalar $Gegner->Nachziehstapel->Karten, 2 ) );
            print '  '
              . $Gegner->Name
              . ' deckt '
              . Kartenliste(@aufgedeckte_Karten)
              . " auf.\n"
              if $ENV{DEBUG};
            for (@aufgedeckte_Karten) {
                if ( $_->can('Geld') ) { push @Geldkarten, $_ }
                else                   { $Gegner->Ablagestapel->add($_) }
            }
        }
        return unless @Geldkarten;

        my ($Geldkarte_zum_Entsorgen) =
            @Geldkarten == 1
          ? @Geldkarten
          : $entscheide_welche_entsorgen->( $Gegner, @Geldkarten );
        croak(  'Bei einem Angriff mit einem Dieb muss die erste übergebene '
              . 'Routine entscheiden, welche Geldkarte entsorgt werden soll.' )
          unless defined $Geldkarte_zum_Entsorgen
              && $Geldkarte_zum_Entsorgen->can('Geld');
        require Dominion::Vorrat;
        my $Geldkarten = Dominion::Vorrat->new( \@Geldkarten );
        $Geldkarten->sub($Geldkarte_zum_Entsorgen);
        $Gegner->Ablagestapel->add( $Geldkarten->Karten );
        print '  '
          . $Gegner->Name
          . ' muss '
          . Kartenliste($Geldkarte_zum_Entsorgen)
          . " entsorgen.\n"
          if $ENV{DEBUG};

        push @entsorgte_Geldkarten, $Geldkarte_zum_Entsorgen;
    }

    return unless @entsorgte_Geldkarten;

    if ( my @Karten_zum_Nehmen =
        $entscheide_welche_nehmen->(@entsorgte_Geldkarten) )
    {
        require Dominion::Vorrat;
        $Spieler->Ablagestapel->add(@Karten_zum_Nehmen);
        print ' nimmt '
          . Kartenliste(@Karten_zum_Nehmen)
          . " von den entsorgten Karten.\n"
          if $ENV{DEBUG};
        ( my $entsorgte_Geldkarten =
              Dominion::Vorrat->new( \@entsorgte_Geldkarten ) )
          ->sub(@Karten_zum_Nehmen);
        @entsorgte_Geldkarten = $entsorgte_Geldkarten->Karten;
    }
    $Spieler->Spiel->Muell->add(@entsorgte_Geldkarten);
}

1;
