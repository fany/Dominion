use strict;
use utf8;
use warnings;

package Dominion::Karte;

sub Name {
    my $package = shift;
    $package =~ s/^Dominion::Karte:://;
    $package;
}

1;
