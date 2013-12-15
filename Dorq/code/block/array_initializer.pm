use strict;
use utf8;

package Dorq::code::block::array_initializer;

use base 'Dorq::code::block';

use Scalar::Util 'refaddr';

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

	my @dereferenced_output = ();
	my %seen = ();

	while( defined( my $node = shift @output ) )
	{
		next if $seen{ refaddr( $node ) } ++;

		if( $node -> isa( 'Dorq::link' ) )
		{
			$node = $node -> val();

			next if $seen{ refaddr( $node ) } ++;
		}

		push @dereferenced_output, \$node;
	}

	return Dorq::array -> new( \@dereferenced_output );
}

-1;

