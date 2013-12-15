use strict;
use utf8;

package Dorq::op::binary;

use base 'Dorq::op';

sub prio { 0 }

sub exec
{
	my $ref     = ( ref( $_[ 0 ] ) or $_[ 0 ] );
	my $pos     = $_[ 1 ];
	my $tokens  = $_[ 2 ];
	my $context = $_[ 3 ];

	$ref =~ s/^.*\:\://;
	$ref = 'op_' . $ref;

#	my $after = sub{ 1 };

	my $a = $tokens -> [ $pos - 1 ];
	my $b = $tokens -> [ $pos + 1 ];

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

#	print &Data::Dumper::Dumper( [ $a, $b ] ) . "\n";

	if( $a -> isa( 'Dorq::var' ) )
	{
		$a = $context -> get( $a ) -> val();
	}

	if( $b -> isa( 'Dorq::var' ) )
	{
		$b = $context -> get( $b ) -> val();
	}

# require Carp;
# &Carp::cluck( &Data::Dumper::Dumper( [ $a, $b ] ) );

#	print &Data::Dumper::Dumper( [ $a, $b ] ) . "\n";

	if( $a -> isa( 'Dorq::type' ) and $b -> isa( 'Dorq::type' ) )
	{
		my $val = $a -> $ref( $b );

		$tokens -> [ $pos - 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos - 1 ] -> isa( 'Dorq::link' );
		$tokens -> [ $pos + 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos + 1 ] -> isa( 'Dorq::link' );

		# $after -> ();

		return $tokens -> [ $pos ] = Dorq::link -> new( \sub{ $val } );
	}

	die sprintf( 'Unknown operation: %s -> %s( %s )', ( ref( $a ) or $a ), $ref, ( ref( $b ) or $b ) );
}

-1;

