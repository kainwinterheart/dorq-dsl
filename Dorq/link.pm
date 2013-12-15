use strict;
use utf8;

package Dorq::link;

use base 'Dorq::object';

sub relink
{
	my ( $val, $code ) = @_;

	my @all  = ();
	my %seen = ();

	while( $val -> isa( 'Dorq::link' ) )
	{
		die 'Loophole' if $seen{ $val } ++;
		push @all, $val;
		$val = $$val -> ();
	}

	foreach my $link ( @all )
	{
		$$link = $$code;
	}

	return 1;
}

sub val
{
	my $val  = shift;
	my %seen = ();

	while( $val -> isa( 'Dorq::link' ) )
	{
		die 'Loophole' if $seen{ $val } ++;

		$val = $$val -> ();
	}

	return $val;
}

-1;

