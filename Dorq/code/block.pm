use strict;
use utf8;

package Dorq::code::block;

use base 'Dorq::code';

sub make_recompillable
{
	my $self  = shift;
	my $codes = $self -> val();

	foreach my $token ( @$codes )
	{
		if( $token -> isa( 'Dorq::code' ) and not $token -> isa( 'Dorq::code::recompillable' ) )
		{
			$token = $token -> make_recompillable();
		}
	}

	return $self;
}

sub exec
{
	my $codes   = shift -> val();
	my $context = shift;
	my $do_not_swap_context = shift;
	my @output  = ();

	$context = Dorq::context -> new( $context ) unless $do_not_swap_context;

	foreach my $code ( @$codes )
	{
#print &Data::Dumper::Dumper($code,$r)."\n";
		push @output, $code -> exec( $context );
	}
return pop @output;
#	return ( ( scalar( @output ) > 1 ) ? Dorq::code::block -> new( \\@output ) -> exec( $context ) : shift( @output ) );
}

-1;

