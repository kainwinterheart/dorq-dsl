use strict;
use utf8;

package Dorq::code::block::builtin;

use base 'Dorq::code::block';

sub exec
{
	return shift -> val() -> ( @_ );
}

-1;

