use strict;
use utf8;

package Dorq::type::num;

use base 'Dorq::type';

sub public
{
	return [
		@{ $_[ 0 ] -> SUPER::public() },
		'times'
	];
}

sub times
{
	my ( $self, $context ) = @_;

	my $ilambda = $context -> get( Dorq::var -> new( \(my $dummy = '$code' ) ) ) -> val();

	die sprintf( 'unknown code: %s', $ilambda ) unless $ilambda -> isa( 'Dorq::lambda' );

	my $local_context = Dorq::context -> new( $context );

	my $limit = abs( $self -> val() );

	for( my $i = 0; $i < $limit; ++$i )
	{
		my $el = Dorq::var -> new( \( my $dummy = '$element' ) );

		$el -> set_val( Dorq::type::num -> new( \( my $dummy = $i ) ) );

		$local_context -> add( $el );

		$ilambda -> call( $local_context );
	}

	return;
}

sub cast_num
{
	return shift;
}

sub cast_string
{
	return Dorq::type::string -> new( \$_[ 0 ] -> val() );
}

sub op_add
{
	return $_[ 0 ] -> new( \( $_[ 0 ] -> val() + $_[ 1 ] -> cast_num() -> val() ) );
}

sub op_mul
{
	return $_[ 0 ] -> new( \( $_[ 0 ] -> val() * $_[ 1 ] -> cast_num() -> val() ) );
}

sub op_div
{
	return $_[ 0 ] -> new( \( $_[ 0 ] -> val() / $_[ 1 ] -> cast_num() -> val() ) );
}

sub op_subtr
{
	return $_[ 0 ] -> new( \( $_[ 0 ] -> val() - $_[ 1 ] -> cast_num() -> val() ) );
}

sub op_mod
{
	return $_[ 0 ] -> new( \( $_[ 0 ] -> val() % $_[ 1 ] -> cast_num() -> val() ) );
}

sub op_eq
{
	return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() == $_[ 1 ] -> cast_num() -> val() ) ) );
}

sub op_gt
{
	return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() > $_[ 1 ] -> cast_num() -> val() ) ) );
}

sub op_lt
{
	return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() < $_[ 1 ] -> cast_num() -> val() ) ) );
}

sub op_gte
{
	return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() >= $_[ 1 ] -> cast_num() -> val() ) ) );
}

sub op_lte
{
	return Dorq::type::bool -> new( \( my $dummy = ( $_[ 0 ] -> val() <= $_[ 1 ] -> cast_num() -> val() ) ) );
}

-1;

