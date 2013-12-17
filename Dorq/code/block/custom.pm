use strict;
use utf8;

package Dorq::code::block::custom;

use base 'Dorq::code::block';

sub new
{
	return $_[ 0 ] -> SUPER::new( { name => $_[ 1 ], value => $_[ 2 ] } );
}

sub val
{
	return ${ $_[ 0 ] -> { 'value' } };
}

sub name
{
	return $_[ 0 ] -> { 'name' };
}

sub exec
{
	return shift -> val() -> ( @_ );
}

sub parental_context
{
	return ${ $_[ 0 ] -> { 'parental_context' } };
}

sub set_parental_context
{
	return ${ $_[ 0 ] -> { 'parental_context' } = \$_[ 1 ] };
}

-1;

