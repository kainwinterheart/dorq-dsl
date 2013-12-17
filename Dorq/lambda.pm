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

	$context = Dorq::context -> new( $context );

	$context -> localize();
	$context -> set_parent( $self -> parental_context() );

	return $self -> val() -> ( $context );
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

