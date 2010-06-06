die "Wird nicht mehr verwendet.\n";

use strict;
use utf8;
use warnings;

package Dominion::Hand;

# eigenes Package für aussagekräftigere Fehlermeldungen

use base 'Dominion::Vorrat';

__PACKAGE__->meta->make_immutable;

1;

__END__

alternative Implementierung:

use base 'Dominion::Stapel';

use Carp qw(croak);
use Dominion qw(Kartenliste);

sub sub {
    my $self = shift;
    my %Karten;
    ++$Karten{$_} for @_;
    @{ $self->_Karten } = (
        grep {
            if ( exists $Karten{$_} )
            {
                --$Karten{$_} || delete $Karten{$_};
                '';
            }
            else { 1 }
          } $self->Karten
    );
    croak( ref($self) . ' enthält keine ' . Kartenliste(%Karten) . '.' )
      if keys %Karten;
    @_;
}

1;
