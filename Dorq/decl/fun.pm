use strict;
use utf8;

package Dorq::decl::fun;

use base 'Dorq::decl';

use Scalar::Util 'weaken';

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

	my $name = $tokens -> [ $pos + 1 ];
	my $code = $tokens -> [ $pos + 2 ];

	if( $name -> isa( 'Dorq::link' ) )
	{
		my $oname = $name;
		$name = $name -> val();
		$oname -> relink( \sub{ return $tokens -> [ $pos ] } );
	}

	if( $code -> isa( 'Dorq::link' ) )
	{
		my $ocode = $code;
		$code = $code -> val();
		$ocode -> relink( \sub{ return $tokens -> [ $pos ] } );
	}

	if( $name -> isa( 'Dorq::function' ) and $code -> isa( 'Dorq::code::block' ) )
	{
		my $var = $code;

		unless( $var -> isa( 'Dorq::code::block::custom' ) )
		{
			$var -> make_recompillable();

			$var = Dorq::code::block::custom -> new( $name -> name(), \sub{ shift; $code -> exec( @_ ) } );
		}

		{
			weaken( my $weak = $context );

			$var -> set_parental_context( $weak );
		}

		$context -> add( $var );

		$tokens -> [ $pos + 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos + 1 ] -> isa( 'Dorq::link' );
		$tokens -> [ $pos + 2 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos + 2 ] -> isa( 'Dorq::link' );

		return $tokens -> [ $pos ] = Dorq::link -> new( \sub{ $context -> get( $var ) } );
	}

	die 'Cannot add to context: ' . $name . ' + ' . $code;
}

-1;

