use strict;
use utf8;
use warnings;

package Dominion;

use base 'Exporter';

our @EXPORT_OK = qw(Karte Kartenliste);

use constant SUBST => {
    'Ä' => 'Ae',
    'Ö' => 'Oe',
    'Ü' => 'Ue',
    'ß' => 'ss',
    'ä' => 'ae',
    'ö' => 'oe',
    'ü' => 'ue',
};

my %Karte;
sub Karte($) {
    my $typ = shift;
    return $Karte{$typ} if exists $Karte{$typ};
    my $package = $typ;
    $package =~ s/(${\ join '|', map quotemeta, keys %{+SUBST} })/ SUBST->{$1} /ego;
    $package = "Dominion::Karte::$package" if $package !~ /::/;
    eval "require $package";
    die $@ if length $@;
    $Karte{$typ} = $package;
}

sub Kartenliste {
    my %Karten;
    ++$Karten{$_} for @_;
    my $mehrere;
    for ( values %Karten ) {
        next if $_ == 1;
        $mehrere = 1;
        last;
    }
    join ' + ', map {
        ( my $kurz = $_ ) =~ s/^Dominion::Karte:://;
        $mehrere ? "$Karten{$_}x $kurz" : $kurz;
    } sort keys %Karten;
}

1;

__END__

500 Karten
* 130 Geldkarten
** 60 Kupfer
** 40 Silber
** 30 Gold
* 48 Punktekarten
** 24 Anwesen
** 12 Herzogtümer
** 12 Provinzen
* 1 Müllkarte
* 252 Königreichkarten
** 24x10 Aktionskarten
** 12 Punktekarte "Gärten"
