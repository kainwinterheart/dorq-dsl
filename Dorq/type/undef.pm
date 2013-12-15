use strict;
use utf8;

package Dorq::type::undef;

use base 'Dorq::type';

sub val
{
	return 'undef';
}

-1;

