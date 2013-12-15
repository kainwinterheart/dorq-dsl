use strict;
use utf8;

package Dorq::context;

use base 'Dorq::object';

sub new
{
	return $_[ 0 ] -> SUPER::new( { parent => $_[ 1 ] } );
}

sub add
{
	$_[ 0 ] -> { 'data' } -> { $_[ 1 ] -> name() } = \$_[ 1 ];
# print "CADD\n";
#print &Data::Dumper::Dumper( $_[ 0 ] . '' );
	return $_[ 0 ] -> get( $_[ 1 ] );
}

sub has
{
	if( exists $_[ 0 ] -> { 'data' } -> { $_[ 1 ] -> name() } )
	{
		return 1;
	}

	if( my $p = $_[ 0 ] -> { 'parent' } )
	{
		return $p -> has( $_[ 1 ] );
	}
}

sub get
{
	if( exists $_[ 0 ] -> { 'data' } -> { $_[ 1 ] -> name() } )
	{
		return ${ $_[ 0 ] -> { 'data' } -> { $_[ 1 ] -> name() } };
	}

	if( my $p = $_[ 0 ] -> { 'parent' } )
	{
		return $p -> get( $_[ 1 ] );
	}

	die 'Unexistent entity: ' . $_[ 1 ] -> name();
}

sub vars
{
	return map{ Dorq::var -> new( \$_ ) } keys %{ $_[ 0 ] -> { 'data' } };
}

sub localize
{
	my $self = shift;

	if( defined( my $parent = $self -> { 'parent' } ) )
	{
		$self -> { 'parent' } = undef;

		foreach my $name ( $parent -> vars() )
		{
			unless( $self -> has( $name ) )
			{
				$self -> add( $parent -> get( $name ) );
			}
		}
	}

	return 1;
}

-1;

