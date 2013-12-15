use strict;
use utf8;

package Dorq::type::string;

use base 'Dorq::type';

sub public
{
	return [
		'split'
	];
}

sub split
{
	my ( $self, $context ) = @_;

	my $re = &Dorq::internals::du( $_[ 1 ] -> get( Dorq::var -> new( \(my $dummy = '$re' ) ) ) -> val() -> cast_string() -> val() );

	my @list = map{

		\( my $dummy2 = Dorq::type::string -> new( \( my $dummy = &Dorq::internals::eu( $_ ) ) ) )

	} split( /$re/, &Dorq::internals::du( $self -> val() ) );

	return Dorq::array -> new( \@list );
}

sub cast_string
{
	return shift;
}

sub cast_num
{
	return Dorq::type::num -> new( \int( $_[ 0 ] -> val() ) );
}

sub op_add
{
        return $_[ 0 ] -> new( \( $_[ 0 ] -> val() . $_[ 1 ] -> cast_string() -> val() ) );
}

sub op_eq
{
        return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() eq $_[ 1 ] -> cast_string() -> val() ) ) );
}

sub op_gt
{
        return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() gt $_[ 1 ] -> cast_string() -> val() ) ) );
}

sub op_lt
{
        return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() lt $_[ 1 ] -> cast_string() -> val() ) ) );
}

sub op_gte
{
        return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() ge $_[ 1 ] -> cast_string() -> val() ) ) );
}

sub op_lte
{
        return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() le $_[ 1 ] -> cast_string() -> val() ) ) );
}

-1;

