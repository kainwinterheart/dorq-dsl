use strict;
use utf8;

package Dorq::code::recompillable;

use base 'Dorq::code';

sub make_recompillable
{
	return shift;
}

sub exec
{
	my ( $self, @rest ) = @_;

	my $tokens = &Dorq::internals::clone( $self -> val() );

	return Dorq::code -> new( \$tokens ) -> exec( @rest );
}

-1;

