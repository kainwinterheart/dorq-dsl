use strict;
use utf8;

package Dorq::loop::last_exc;

use base 'Dorq::object';

sub new
{
	shift -> SUPER::new( \( my $dummy = undef ) );
}

-1;

