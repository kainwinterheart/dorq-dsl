use strict;
use utf8;

package Dorq::type;

use base 'Dorq::object';

sub val
{
	return ${ +shift };
}

-1;

