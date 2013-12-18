use strict;
use utf8;

package Dorq::array;

use base 'Dorq::type';

use Scalar::Util 'blessed';

sub new
{
	return $_[ 0 ] -> SUPER::new( { list => ( $_[ 1 ] || [] ) } );
}

sub public
{
	return [
		'push',
		'unshift',
		'size',
		'shift',
		'pop',
		'get',
		'set',
		'each'
	];
}

sub val
{
	return shift -> { 'list' };
}

sub push
{
	my ( $self, $context ) = @_;

	my @els   = ();
	my $input = $context -> get( Dorq::var -> new( \(my $dummy = '$list' ) ) ) -> val();

	die 'input should be an array' unless $input -> isa( 'Dorq::array' );

	foreach( @{ $input -> { 'list' } } )
	{
		die 'Unknown value: ' . ${ $_ } unless blessed( ${ $_ } ) and ${ $_ } -> isa( 'Dorq::object' );

		CORE::push @els, $_;
	}

	CORE::push @{ $self -> { 'list' } }, @els;

	return;
}

sub unshift
{
	my ( $self, $context ) = @_;

	my @els   = ();
	my $input = $context -> get( Dorq::var -> new( \(my $dummy = '$list' ) ) ) -> val();

	die 'input should be an array' unless $input -> isa( 'Dorq::array' );

	foreach( @{ $input -> { 'list' } } )
	{
		die 'Unknown value: ' . ${ $_ } unless blessed( ${ $_ } ) and ${ $_ } -> isa( 'Dorq::object' );

		CORE::push @els, $_;
	}

	CORE::unshift @{ $self -> { 'list' } }, @els;

	return;
}

sub size
{
	return Dorq::type::num -> new( \( my $dummy = scalar( @{ $_[ 0 ] -> { 'list' } } ) ) );
}

sub shift
{
	my $self = shift;

	if( scalar( @{ $self -> { 'list' } } ) > 0 )
	{
		return ${ CORE::shift @{ $self -> { 'list' } } };
	}

	return Dorq::type::undef -> new( \( my $dummy = undef ) );
}

sub pop
{
	my $self = shift;

	if( scalar( @{ $self -> { 'list' } } ) > 0 )
	{
		return ${ CORE::pop @{ $self -> { 'list' } } };
	}

	return Dorq::type::undef -> new( \( my $dummy = undef ) );
}

sub set
{
	my ( $self, $context ) = @_;

	my $iidx = $context -> get( Dorq::var -> new( \(my $dummy = '$idx' ) ) ) -> val() -> cast_num();
	my $ival = $context -> get( Dorq::var -> new( \(my $dummy = '$val' ) ) ) -> val();

	die sprintf( 'unknown index: %s', $iidx ) unless $iidx -> isa( 'Dorq::type::num' );
	die sprintf( 'unknown value: %s', $ival ) unless $ival -> isa( 'Dorq::object' );

	return ${ $self -> { 'list' } -> [ $iidx -> val() ] = \$ival };
}

sub get
{
	my ( $self, $context ) = @_;

	my $iidx = $context -> get( Dorq::var -> new( \(my $dummy = '$idx' ) ) ) -> val() -> cast_num();

	die sprintf( 'unknown index: %s', $iidx ) unless $iidx -> isa( 'Dorq::type::num' );

	my $idx_num = $iidx -> val();
	my $size    = scalar( @{ $self -> { 'list' } } );

	if(
		(
			( $idx_num >= 0 ) and
			( $idx_num < $size )
		) or
		(
			( $idx_num < 0 ) and
			( $idx_num >= ( $size * -1 ) )
		)
	)
	{
		return ${ $self -> { 'list' } -> [ $idx_num ] };
	}

	die sprintf( 'invalid index: %d', $idx_num );
}

sub each
{
	my ( $self, $context ) = @_;

	my $ilambda = $context -> get( Dorq::var -> new( \(my $dummy = '$code' ) ) ) -> val();

	die sprintf( 'unknown code: %s', $ilambda ) unless $ilambda -> isa( 'Dorq::lambda' );

	my $local_context = Dorq::context -> new( $context );

	{
		my $var = Dorq::var -> new( \( my $dummy = '$loop' ) );

		$var -> set_val( Dorq::loop::object -> new() );

		$local_context -> add( $var );
	}

	foreach my $_el ( @{ $self -> { 'list' } } )
	{
		my $el = Dorq::var -> new( \( my $dummy = '$element' ) );

		$el -> set_val( ${ $_el } );

		$local_context -> add( $el );

		eval
		{
			$ilambda -> call( $local_context );
		};

		if( my $e = $@ )
		{
			if( blessed $e )
			{
				next if $e -> isa( 'Dorq::loop::next_exc' );
				last if $e -> isa( 'Dorq::loop::last_exc' );
			}

			die $e;
		}
	}

	return;
}

-1;

