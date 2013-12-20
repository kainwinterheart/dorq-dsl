use strict;
use utf8;

package Dorq::hash;

use base 'Dorq::type';

use Scalar::Util 'blessed';

sub new
{
	return $_[ 0 ] -> SUPER::new( { hash => ( $_[ 1 ] || {} ) } );
}

sub public
{
	return [
		@{ $_[ 0 ] -> SUPER::public() },
		'get',
		'set',
		'keys',
		'values',
		'exists',
		'delete'
	];
}

sub val
{
	return shift -> { 'hash' };
}

sub keys
{
	my $self = shift;

	my @out = ();

	foreach my $key ( CORE::keys %{ $self -> { 'hash' } } )
	{
		push @out, \( my $dummy = Dorq::type::string -> new( \$key ) );
	}

	return Dorq::array -> new( \@out );
}

sub values
{
	my $self = shift;

	return Dorq::array -> new( [ CORE::values %{ $self -> { 'hash' } } ] );
}

sub set
{
	my ( $self, $context ) = @_;

	my $ikey = $context -> get( Dorq::var -> new( \(my $dummy = '$key' ) ) ) -> val() -> cast_string();
	my $ival = $context -> get( Dorq::var -> new( \(my $dummy = '$val' ) ) ) -> val();

	die sprintf( 'unknown key: %s', $ikey ) unless $ikey -> isa( 'Dorq::type::string' );
	die sprintf( 'unknown val: %s', $ival ) unless $ival -> isa( 'Dorq::object' );

	return ${ $self -> { 'hash' } -> { $ikey -> val() } = \$ival };
}

sub exists
{
	my ( $self, $context ) = @_;

	my $ikey = $context -> get( Dorq::var -> new( \(my $dummy = '$key' ) ) ) -> val() -> cast_string();

	die sprintf( 'unknown key: %s', $ikey ) unless $ikey -> isa( 'Dorq::type::string' );

	return Dorq::type::bool -> new( \( my $dummy = ( CORE::exists $self -> { 'hash' } -> { $ikey -> val() } ) ) );
}

sub get
{
	my ( $self, $context ) = @_;

	my $ikey = $context -> get( Dorq::var -> new( \(my $dummy = '$key' ) ) ) -> val() -> cast_string();

	die sprintf( 'unknown key: %s', $ikey ) unless $ikey -> isa( 'Dorq::type::string' );

	my $key_str = $ikey -> val();

	if( CORE::exists $self -> { 'hash' } -> { $key_str } )
	{
		return ${ $self -> { 'hash' } -> { $key_str } };
	}

	die sprintf( 'key does not exists: %s', $key_str );
}

sub delete
{
	my ( $self, $context ) = @_;

	my $ikey = $context -> get( Dorq::var -> new( \(my $dummy = '$key' ) ) ) -> val() -> cast_string();

	die sprintf( 'unknown key: %s', $ikey ) unless $ikey -> isa( 'Dorq::type::string' );

	my $key_str = $ikey -> val();

	if( CORE::exists $self -> { 'hash' } -> { $key_str } )
	{
		return ${ delete $self -> { 'hash' } -> { $key_str } };
	}

	die sprintf( 'key does not exists: %s', $key_str );
}

-1;

