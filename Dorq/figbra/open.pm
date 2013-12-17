use strict;
use utf8;

package Dorq::figbra::open;

use base 'Dorq::decl';

sub exec
{
	my $pos     = $_[ 1 ];
	my $tokens  = $_[ 2 ];
	my $context = $_[ 3 ];

	my $code = $tokens -> [ $pos + 1 ];
	my $pair = $tokens -> [ $pos + 2 ];
	my $has_code = 1;

	if( $code -> isa( 'Dorq::figbra::close' ) )
	{
		$has_code = 0;
		$pair = $code;
		$code = Dorq::hash -> new( \( my $dummy = {} ) );

	} else
	{
		die 'Unmatched curly bracket' unless $pair and $pair -> isa( 'Dorq::figbra::close' );

		if( $code -> isa( 'Dorq::code::block' ) and not $code -> isa( 'Dorq::code::block::hash_initializer' ) )
		{
			$code = Dorq::code::block::hash_initializer -> new(
				\( $code -> val() )
			);
		}

		if( $code -> isa( 'Dorq::code::block::hash_initializer' ) )
		{
			$code = $code -> exec( $context, 1 );
		}
	}

	if( $code -> isa( 'Dorq::hash' ) )
	{
		$tokens -> [ $pos + 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos + 1 ] -> isa( 'Dorq::link' );
		$tokens -> [ $pos + 2 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) if $has_code and not $tokens -> [ $pos + 2 ] -> isa( 'Dorq::link' );

		return $tokens -> [ $pos ] = Dorq::link -> new( \sub{ $code } );
	}

	die 'Cannot initialize hash: ' . $code;
}

-1;

