use strict;
use utf8;

package Dorq::decl::lambda;

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

	my $var = $tokens -> [ $pos + 1 ];

	if( $var -> isa( 'Dorq::link' ) )
	{
		my $ovar = $var;
		$var = $var -> val();
		$ovar -> relink( \sub{ return $tokens -> [ $pos ] } );
	}

	if( $var -> isa( 'Dorq::code::block' ) )
	{
		$var -> make_recompillable();

		$tokens -> [ $pos + 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos + 1 ] -> isa( 'Dorq::link' );

#		my $outer_def = Dorq::code::block::custom -> new( 'outer', \sub{ $context -> get( Dorq::var -> new( \( $_[ 1 ] -> get( Dorq::var -> new( \(my $dummy = '$name' ) ) ) -> val() -> cast_string() -> val() ) ) ) -> val() } );

		my $o = Dorq::lambda -> new( sub
		{
			my $local_context = Dorq::context -> new( $_[ 0 ] );

#			$local_context -> add( $outer_def );

# use Data::Dumper 'Dumper';
# print Dumper( $var ), "\n";

			return $var -> exec( $local_context, 1 );
		} );

		{
#			weaken( my $weak = $context );

			$o -> set_parental_context( $context ); # $weak );
		}

		return $tokens -> [ $pos ] = Dorq::link -> new( \sub{ $o } );
	}

	die 'Cannot initialize lambda: ' . $var;
}

-1;

