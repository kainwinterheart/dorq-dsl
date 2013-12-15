use strict;
use utf8;

package Dorq::method::call;

use base 'Dorq::function';

sub exec
{
	substr( ( my $name = $_[ 0 ] -> name() ), 0, 1 ) = "";

	my $pos     = $_[ 1 ];
	my $tokens  = $_[ 2 ];
	my $context = $_[ 3 ];

	my $obj = $tokens -> [ $pos - 1 ];
	my $var = $tokens -> [ $pos + 1 ];

	if( $obj -> isa( 'Dorq::link' ) )
	{
		my $ovar = $obj;
		$obj = $obj -> val();
		$ovar -> relink( \sub{ return $tokens -> [ $pos ] } );
	}

	if( $obj -> isa( 'Dorq::var' ) )
	{
		$obj = $obj -> val();
	}

	if( $var -> isa( 'Dorq::link' ) )
	{
		my $ovar = $var;
		$var = $var -> val();
		$ovar -> relink( \sub{ return $tokens -> [ $pos ] } );
	}

	if( $obj -> isa( 'Dorq::object' ) and $var -> isa( 'Dorq::code::block' ) )
	{
		$context = Dorq::context -> new( $context );

		$var -> exec( $context, 1 );

		$tokens -> [ $pos - 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos - 1 ] -> isa( 'Dorq::link' );
		$tokens -> [ $pos + 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos + 1 ] -> isa( 'Dorq::link' );

		my $result = $obj -> call_public_method( $name, $context );

		return $tokens -> [ $pos ] = Dorq::link -> new( \sub{ $result } );
	}

	die sprintf( 'Cannot exucute method: invalid token sequence ( %s.%s(%s) )', $obj, $name, $var );
}

-1;

