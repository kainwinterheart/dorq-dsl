use strict;
use utf8;

package Dorq::op::assign;

use base 'Dorq::op::binary';

sub prio { 1 }

sub exec
{
	my $ref     = ( ref( $_[ 0 ] ) or $_[ 0 ] );
	my $pos     = $_[ 1 ];
	my $tokens  = $_[ 2 ];
	my $context = $_[ 3 ];

	$ref =~ s/^.*\:\://;
	$ref = 'op_' . $ref;

	my $a = $tokens -> [ $pos - 1 ];
	my $b = $tokens -> [ $pos + 1 ];

	if( $b -> isa( 'Dorq::code' ) )
	{
		$b = $b -> exec( $context );
		$tokens -> [ $pos + 1 ] = $b;

	} elsif( $b -> isa( 'Dorq::link' ) )
	{
		my $ob = $b;
		$b = $b -> val();
		$ob -> relink( \sub{ return $tokens -> [ $pos ] } );
	}

	if( $b -> isa( 'Dorq::var' ) )
	{
		$b = $context -> get( $b ) -> val();
	}

	if( $a -> isa( 'Dorq::code' ) )
	{
		$a = $a -> exec( $context );
		$tokens -> [ $pos - 1 ] = $a;

	} elsif( $a -> isa( 'Dorq::link' ) )
	{
		my $oa = $a;
		$a = $a -> val();
		$oa -> relink( \sub{ return $tokens -> [ $pos ] } );
	}

	if( $a -> isa( 'Dorq::var' ) )
	{
		$a = $context -> get( $a );
	}

#	print &Data::Dumper::Dumper( [ $a, $b ] ) . "\n";

# require Carp;
# &Carp::cluck( &Data::Dumper::Dumper( [ $token ] ) );

	if( $a -> isa( 'Dorq::var' ) and $b -> isa( 'Dorq::type' ) )
	{
		$a -> $ref( $b );

		$tokens -> [ $pos - 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos - 1 ] -> isa( 'Dorq::link' );
		$tokens -> [ $pos + 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos + 1 ] -> isa( 'Dorq::link' );

		return $tokens -> [ $pos ] = Dorq::link -> new( \sub{ $context -> get( $a ) } );
	}

	die sprintf( 'Unknown operation: %s -> %s( %s )', ( ref( $a ) or $a ), $ref, ( ref( $b ) or $b ) );
}

-1;

