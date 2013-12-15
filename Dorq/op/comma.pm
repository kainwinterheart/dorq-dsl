use strict;
use utf8;

package Dorq::op::comma;

use base 'Dorq::op::binary';

sub prio { 2 }

sub exec
{
	my $pos     = $_[ 1 ];
	my $tokens  = $_[ 2 ];
	my $context = $_[ 3 ];

	my $token = $tokens -> [ $pos + 1 ];

	if( $token -> isa( 'Dorq::code' ) )
	{
		$token = $token -> exec( $context );
		$tokens -> [ $pos + 1 ] = $token;

	} elsif( $token -> isa( 'Dorq::link' ) )
	{
		my $otoken = $token;
		$token = $token -> val();
		$otoken -> relink( \sub{ return $tokens -> [ $pos ] } );
	}

	$tokens -> [ $pos + 1 ] = Dorq::link -> new( \sub{ return $tokens -> [ $pos ] } ) unless $tokens -> [ $pos + 1 ] -> isa( 'Dorq::link' );
	return $tokens -> [ $pos ] = Dorq::link -> new( \sub{ $token } );

# require Carp;
# &Carp::cluck( &Data::Dumper::Dumper( [ $token ] ) );

	# return $token;
}

-1;

