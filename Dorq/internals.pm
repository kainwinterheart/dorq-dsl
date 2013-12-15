use strict;
use utf8;

package Dorq::internals;

BEGIN
{
	require Data::Dumper;

	$Data::Dumper::Terse = 1;
	$Data::Dumper::Deparse = 1;
};

use Scalar::Util 'blessed';

use Encode ( 'is_utf8', 'decode', 'encode' );

sub du
{
	my $s = shift;

	return ( is_utf8( $s ) ? $s : decode( 'UTF-8', $s ) );
}

sub eu
{
	my $s = shift;

	my $rv = is_utf8( $s ) ? encode( 'UTF-8', $s ) : $s;

	if( is_utf8( $rv ) )
	{
		utf8::downgrade( $rv );
	}

	return $rv;
}

sub convert_Dorq_object_to_native_perl
{
	my $o = shift;

	if( blessed $o )
	{
		if( $o -> isa( 'Dorq::link' ) )
		{
			$o = $o -> val();
		}

		if( $o -> isa( 'Dorq::var' ) )
		{
			$o = $o -> val();
		}

		if( $o -> isa( 'Dorq::hash' ) )
		{
			return &Dorq::internals::convert_Dorq_hash_to_native_perl( $o );
		}

		if( $o -> isa( 'Dorq::array' ) )
		{
			return &Dorq::internals::convert_Dorq_array_to_native_perl( $o );
		}

		if( $o -> isa( 'Dorq::type' ) )
		{
			return $o -> val();
		}
	}

	return $o;
}

sub convert_Dorq_hash_to_native_perl
{
	my $in = shift;
	my %out = ();

	foreach my $key ( keys %{ $in -> val() } )
	{
		$out{ $key } = &Dorq::internals::convert_Dorq_object_to_native_perl( ${ $in -> { 'hash' } -> { $key } } );
	}

	return \%out;
}

sub convert_Dorq_array_to_native_perl
{
	my $in = shift -> val();
	my @out = ();
	my $cnt = scalar( @$in );

	for( my $i = 0; $i < $cnt; ++$i )
	{
		$out[ $i ] = &Dorq::internals::convert_Dorq_object_to_native_perl( ${ $in -> [ $i ] } );
	}

	return \@out;
}

sub clone
{
	my ( $i, $limit ) = @_;

	if( ++$limit > 10000 )
	{
		require Data::Dumper;

		die Data::Dumper::Dumper( $i );
	}

	if( blessed $i )
	{
		if( $i -> isa( 'Dorq::object' ) )
		{
			return $i -> clone( $limit );
		}

		return $i;
	}

	if( ref( $i ) eq 'HASH' )
	{
		return &Dorq::internals::clone_hash( $i, $limit );
	}

	if( ref( $i ) eq 'ARRAY' )
	{
		return &Dorq::internals::clone_array( $i, $limit );
	}

	if( ref( $i ) eq 'SCALAR' )
	{
		return &Dorq::internals::clone_scalar( $i, $limit );
	}

	return $i;
}

sub clone_hash
{
	my ( $i, $limit ) = @_;
	my %o = ();

	foreach my $key ( %$i )
	{
		$o{ $key } = &Dorq::internals::clone( $i -> { $key }, $limit );
	}

	return \%o;
}

sub clone_array
{
	my ( $i, $limit ) = @_;
	my @o = ();
	my $c = scalar( @$i );

	for( my $j = 0; $j < $c; ++$j )
	{
		$o[ $j ] = &Dorq::internals::clone( $i -> [ $j ], $limit );
	}

	return \@o;
}

sub clone_scalar
{
	my ( $i, $limit ) = @_;
	my $o = &Dorq::internals::clone( $$i, $limit );

	return \$o;
}

-1;

