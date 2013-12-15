use strict;
use utf8;

package Dorq::var;

use base 'Dorq::object';

use Scalar::Util 'blessed';

sub new
{
	return $_[ 0 ] -> SUPER::new( { name => $_[ 1 ] } );
}

sub name
{
	return ${ $_[ 0 ] -> { 'name' } };
}

sub val
{
	unless( exists $_[ 0 ] -> { 'value' } )
	{
		$_[ 0 ] -> { 'value' } = \( my $dummy2 = Dorq::type::undef -> new( \( my $dummy = undef ) ) );
	}
#require Carp;
#&Carp::cluck( &Data::Dumper::Dumper( $_[ 0 ] ) );
	return ${ $_[ 0 ] -> { 'value' } };
}

sub set_val
{
	die 'Unknown value: ' . $_[ 1 ] unless blessed( $_[ 1 ] ) and $_[ 1 ] -> isa( 'Dorq::object' );

	$_[ 0 ] -> { 'value' } = \$_[ 1 ];

	return $_[ 0 ] -> val();
}

sub op_assign
{
	return $_[ 0 ] -> set_val( $_[ 1 ] );
}

-1;

