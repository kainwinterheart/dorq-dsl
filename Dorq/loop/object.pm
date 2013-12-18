use strict;
use utf8;

package Dorq::loop::object;

use base 'Dorq::object';

sub new
{
	return shift -> SUPER::new( {} );
}

sub public
{
	return [
		'next',
		'last'
	];
}

sub next
{
	CORE::next LAST_CALLED_LOOP;
}

sub last
{
	CORE::last LAST_CALLED_LOOP;
}

-1;

