use strict;
use utf8;

package Dorq::object;

use Scalar::Util 'reftype';

sub new
{
	return bless( $_[ 1 ], ( ref( $_[ 0 ] ) or $_[ 0 ] ) );
}

sub clone
{
	my ( $self, $limit ) = @_;
	my $rt = reftype( $self );
	my $new = undef;

	if( $rt eq 'HASH' )
	{
		my %hash = %$self;

		$new = &Dorq::internals::clone( \%hash, $limit );

	} elsif( $rt eq 'ARRAY' )
	{
		my @array = @$self;

		$new = &Dorq::internals::clone( \@array, $limit );

	} else
	{
		my $value = $$self;

		$new = &Dorq::internals::clone( \$value, $limit );
	}

	return bless( $new, ( ref( $self ) or $self ) );
}

sub public { [] }

sub call_public_method
{
	my ( $self, $method, @args ) = @_;

	foreach my $m ( @{ $self -> public() } )
	{
#		warn sprintf('has:%s,need:%s,eq:%d',$m,$method,($m eq $method));
		if( $m eq $method )
		{
			return $self -> $m( @args );
		}
	}

	die sprintf( '%s has no such method: %s', ref( $self ), $method );
}

-1;

