use strict;
use utf8;

package Dorq::lambda;

use base 'Dorq::type';

use Scalar::Util 'blessed';

sub new
{
	return $_[ 0 ] -> SUPER::new( { code => ( $_[ 1 ] || sub{} ) } );
}

sub public
{
	return [
		'call'
	];
}

sub val
{
	return shift -> { 'code' };
}

sub call
{
	my ( $self, $context ) = @_;

	return $self -> val() -> ( $context );
}

-1;

