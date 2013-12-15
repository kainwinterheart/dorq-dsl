use strict;
use utf8;

package Dorq::decl::hash;

use base 'Dorq::decl';

sub new
{
	my $val = $_[ 0 ] -> SUPER::new( $_[ 1 ] );

#	use Data::Dumper 'Dumper';
#	print Dumper( $val ) . "\n";

	return $val;
}

sub exec
{
	my $pos     = $_[ 1 ];
	my $tokens  = $_[ 2 ];
	my $context = $_[ 3 ];

	my $var = $tokens -> [ $pos + 1 ];

	if( $var -> isa( 'Dorq::link' ) )
	{
		my $ovar = $var;
		$var = $var -> val();
		$ovar -> relink( \sub{ return $tokens -> [ $pos ] } );
	}

	if( $var -> isa( 'Dorq::code::block' ) and not $var -> isa( 'Dorq::code::block::hash_initializer' ) )
	{
		$var = Dorq::code::block::hash_initializer -> new(
			\( $var -> val() )
		);
	}

	if( $var -> isa( 'Dorq::code::block::hash_initializer' ) )
	{
		$var = $var -> exec( $context, 1 );
	}

	if( $var -> isa( 'Dorq::hash' ) )
	{
		$tokens -> [ $pos + 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos + 1 ] -> isa( 'Dorq::link' );

		return $tokens -> [ $pos ] = Dorq::link -> new( \sub{ $var } );
	}

	die 'Cannot initialize hash: ' . $var;
}

-1;

