use strict;
use utf8;

package Dorq::type::bool;

use base 'Dorq::type';

sub val
{
	return ( $_[ 0 ] -> SUPER::val() ? 'true' : 'false' );
}

sub cast_string
{
	return Dorq::type::string -> new( \$_[ 0 ] -> val() );
}

-1;

