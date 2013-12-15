use strict;
use utf8;

package Dorq::code;

use base 'Dorq::type';

use Scalar::Util 'blessed';

sub exec
{
	my $tokens  = shift -> val();
	return unless scalar ( @$tokens ) > 0;
	my $context = shift;
#	$context = $$context if ref $context and not blessed $context;
# print "CTX: $context\n";
#	my @output  = ();
#die &Data::Dumper::Dumper($tokens) if scalar @$tokens > 2;

	my $highest_op_lvl = 0;
	my $has_ops        = 0;

# print &Data::Dumper::Dumper($tokens);
	for( my $i = 0; $i < scalar( @$tokens ); ++$i )
	{
		my $token = $tokens -> [ $i ];

#		unless( $token )
#		{
#			$tokens -> [ $i ] = $token = Dorq::type::undef -> new( \( my $dummy = undef ) );
#		}

# print &Data::Dumper::Dumper($tokens)."\n";
		if( $token -> isa( 'Dorq::code' ) )
		{
			$tokens -> [ $i ] = $token -> exec( $context );

		} elsif( $token -> isa( 'Dorq::decl' ) )
		{
			$tokens -> [ $i ] = $token -> exec( $i, $tokens, $context );

		} elsif( $token -> isa( 'Dorq::var' ) )
		{
			$tokens -> [ $i ] = $context -> get( $token );

		} elsif( $token -> isa( 'Dorq::function' ) )
		{
			$tokens -> [ $i ] = $token -> exec( $i, $tokens, $context );

		} elsif( $token -> isa( 'Dorq::op' ) )
		{
			$has_ops = 1;

			if( $highest_op_lvl < ( my $prio = $token -> prio() ) )
			{
				$highest_op_lvl = $prio;
			}
		}
	}

	my $highest_op_lvl_is_set = 1;

#die &Data::Dumper::Dumper($tokens) if scalar @$tokens > 2;
#	print &Data::Dumper::Dumper( [ 'mid result', $tokens ] ) . "\n";
# print &Data::Dumper::Dumper($tokens)."\n";
	while( $has_ops )
	{
		$has_ops = 0;

		for( my $i = 0; $i < scalar( @$tokens ); ++$i )
		{
			my $token = $tokens -> [ $i ];

#			unless( $token )
#			{
#				$tokens -> [ $i ] = $token = Dorq::type::undef -> new( \( my $dummy = undef ) );
#die &Data::Dumper::Dumper($tokens)."\n";
#			}

# print &Data::Dumper::Dumper($tokens)."\n";
			if( $token -> isa( 'Dorq::op' ) )
			{
				$has_ops = 1;

				if( $highest_op_lvl_is_set )
				{
					if( $token -> prio() == $highest_op_lvl )
					{
						# print &Data::Dumper::Dumper( [ 'exec', $tokens, $token ] ) . "\n";
						$tokens -> [ $i ] = $token -> exec( $i, $tokens, $context );
					}
					else
					{
						# print &Data::Dumper::Dumper( [ 'skip', $tokens, $token ] ) . "\n";
					}
				} else
				{
						# print &Data::Dumper::Dumper( [ 'scan', $tokens, $token ] ) . "\n";
					if( $highest_op_lvl < ( my $prio = $token -> prio() ) )
					{
						$highest_op_lvl = $prio;
						# print &Data::Dumper::Dumper( [ 'scan ok', $tokens, $token ] ) . "\n";
					}
				}
			}
		}

		unless( $highest_op_lvl_is_set = not $highest_op_lvl_is_set )
		{
			$highest_op_lvl = 0;
		}
	}
	# print &Data::Dumper::Dumper( [ 'result', $tokens ] ) . "\n";
# die &Data::Dumper::Dumper($tokens) if scalar @$tokens > 2;
# die &Data::Dumper::Dumper($context) if scalar @$tokens > 2;
	return $tokens -> [ $#$tokens ];
#print &Data::Dumper::Dumper( \@output )."\n";
# print &Data::Dumper::Dumper( $tokens )."\n";
#print &Data::Dumper::Dumper($context)."\n";
#die &Data::Dumper::Dumper($tokens) if scalar @$tokens > 2;
#	return ( ( scalar( @output ) > 1 ) ? Dorq::code -> new( \\@output ) -> exec( $context ) : ( ( scalar( @output ) == 1 ) ? shift( @output ) : pop( @$tokens ) ) );
}

sub make_recompillable
{
	my $codes = shift -> val();
	my @codes = ();

	foreach my $token ( @$codes )
	{
		my $new_token = $token;

		if( $new_token -> isa( 'Dorq::code' ) and not $new_token -> isa( 'Dorq::code::recompillable' ) )
		{
			$new_token = $new_token -> make_recompillable();
		}

		push @codes, $new_token;
	}

	return Dorq::code::recompillable -> new( \\@codes );
}

-1;

