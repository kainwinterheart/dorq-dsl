use strict;
use utf8;

package Dorq::globalstate;

my %storage = ();

sub get
{
	return $storage{ +shift };
}

sub set
{
	my ( $key, $val ) = @_;

	return $storage{ $key } = $val;
}

-1;

