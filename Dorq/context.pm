use strict;
use utf8;

package Dorq::context;

use base 'Dorq::object';

use Scalar::Util 'weaken';

sub new
{
	my $self = $_[ 0 ] -> SUPER::new( { parent => $_[ 1 ] } );

	weaken( my $weak = $self );

	my $var = Dorq::var -> new( \( my $dummy = '$context' ) );

	$var -> set_val( $weak );

	$self -> add( $var );

	return $self;
}

sub public
{
	return [
		'exists',
		'localize'
	];
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

sub exists
{
	my ( $self, $ctx ) = @_;

	my $name = $ctx -> get( Dorq::var -> new( \( my $dummy = '$name' ) ) ) -> val();

	die '$name should be a string' unless $name -> isa( 'Dorq::type::string' );

	my $result = $self -> has( Dorq::var -> new( \( my $dummy = $name -> val() ) ) );

	return Dorq::type::bool -> new( \( my $dummy = ( $result ? 1 : 0 ) ) );
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

	return Dorq::type::undef -> new( \( my $dummy = undef ) );
}

sub set_parent
{
	return $_[ 0 ] -> { 'parent' } = $_[ 1 ];
}

-1;

