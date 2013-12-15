use strict;
use utf8;

package Dorq::function;

use base 'Dorq::object';

sub name
{
	return ${ +shift };
}

sub exec
{
	my $pos     = $_[ 1 ];
	my $tokens  = $_[ 2 ];
	my $context = $_[ 3 ];

	my $var = $tokens -> [ $pos + 1 ];

	my $body = ( $context -> has( $_[ 0 ] ) ? $context -> get( $_[ 0 ] ) : do{ my $n = 'Dorq::builtins::' . $_[ 0 ] -> name(); ( \&$n ) -> (); } );

	if( $var -> isa( 'Dorq::code' ) and $body -> isa( 'Dorq::code::block' ) )
	{
		my $context = Dorq::context -> new( $context );

# die &Data::Dumper::Dumper( $var );
# print &Data::Dumper::Dumper( $context );
		$var -> exec( $context, ( $var -> isa( 'Dorq::code::block' ) ? 1 : () ) );
# die &Data::Dumper::Dumper( $context );
#		$context -> localize();
# print &Data::Dumper::Dumper( $context );

		my $result = $body -> exec( $context );

		$tokens -> [ $pos + 1 ] = Dorq::link -> new( \sub{ $tokens -> [ $pos ] } );

		return $tokens -> [ $pos ] = Dorq::link -> new( \sub{ $result } );
	}

	die sprintf( 'Ivalid function call: %s( %s )', $body, $var );
}

-1;

