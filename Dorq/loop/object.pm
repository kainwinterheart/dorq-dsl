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
	die Dorq::loop::next_exc -> new();
}

sub last
{
	die Dorq::loop::last_exc -> new();
}

-1;

