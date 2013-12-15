use strict;
use utf8;

package Dorq::Runner;

my %table  = (
	op_assign    => qr/^\=(?!(\s))$/,
	op_add       => qr/^\+(?!(\s))$/,
	op_mul       => qr/^\*(?!(\s))$/,
	op_div       => qr/^\/(?!(\s))$/,
	op_subtr     => qr/^\-(?!(\s))$/,
	op_mod       => qr/^\%(?!(\s))$/,
	op_eq        => qr/^\=\=(?!(\s))$/,
	op_gt        => qr/^\>(?!(\s))$/,
	op_lt        => qr/^\<(?!(\s))$/,
	op_gte       => qr/^\>\=(?!(\s))$/,
	op_lte       => qr/^\<\=(?!(\s))$/,
	comment	     => qr/\#.+?[\n]?$/,
	type_string  => {
		from_re  => qr/^\"./,
		to_re    => qr/[^\\]+\"(?!(\s))$/,
		trans_to => sub
		{
			my $s = shift;

			$s =~ s/(\\\\)+//g;

			return $s;
		}
	},
	var          => qr/^\$[a-z_][a-z0-9_]*(?!(\s))$/i,
	decl_lambda  => {
		from_re       => qr/^lambda(?=((\s|\()$))/,
		to_re         => qr/^lambda(?=((\s|\()$))/,
		after         => sub
		{
			my ( $word, $chars ) = @_;

			unshift @$chars, chop $word;
		}
	},
	decl_hash    => {
		from_re       => qr/^hash(?=((\s|\()$))/,
		to_re         => qr/^hash(?=((\s|\()$))/,
		after         => sub
		{
			my ( $word, $chars ) = @_;

			unshift @$chars, chop $word;
		}
	},
	decl_array   => {
		from_re       => qr/^array(?=((\s|\()$))/,
		to_re         => qr/^array(?=((\s|\()$))/,
		after         => sub
		{
			my ( $word, $chars ) = @_;

			unshift @$chars, chop $word;
		}
	},
	decl_var     => {
		from_re       => qr/^let(?=((\s|\$)$))/,
		to_re         => qr/^let(?=((\s|\$)$))/,
		after         => sub
		{
			my ( $word, $chars ) = @_;

			unshift @$chars, chop $word;
		}
	},
	decl_fun     => {
		from_re       => qr/^defun(?=((\s|\$)$))/,
		to_re         => qr/^defun(?=((\s|\$)$))/,
		after         => sub
		{
			my ( $word, $chars ) = @_;

			unshift @$chars, chop $word;
		}
	},
	type_num     => qr/^[-]?[0-9]+(?!(\s))$/,
	separator    => qr/^\;(?!(\s))$/,
	separator2   => qr/^\=\>(?!(\s))$/,
	op_comma     => qr/^\,(?!(\s))$/,
	parens_open  => qr/^\((?!(\s))$/,
	parens_close => qr/^\)(?!(\s))$/,
	method_call  => qr/^\.[a-z_][a-z0-9_]*(?!(\s))$/i,
	function     => qr/^[a-z_][a-z0-9_]*(?!(\s))$/i,
);

sub eval_string
{

my $string = shift;
my @tokens = ();

my @chars = split( //, $string );

while( defined( my $first_char = shift @chars ) )
{
	my $word = $first_char;
	my $id   = &get_category( $word, \@chars );

#	warn sprintf( '"%s":"%s"', $word, $id );
	while( defined( my $next_char = shift @chars ) )
	{
		if( my $next_id = &get_category( ( my $next_word = ( $word . $next_char ) ), \@chars ) )
		{
#			warn sprintf( '"%s":"%s"', $next_word, $next_id );
			$id   = $next_id;
			$word = $next_word;
		} else
		{
#			warn sprintf( '"%s":"%s"', $next_word, $next_id );
			unshift @chars, $next_char;
			last;
		}
	}

	if( length( $word ) )
	{
		if( $id )
		{
#		warn sprintf( 'adding => "%s":"%s"', $word, $id );
			unless( $id eq 'comment' )
			{
				push @tokens, { $id => $word };
			}

		} elsif( $word !~ m/^\s+$/ )
		{
			die 'Lexemme is unknown: ' . $word;
		}
	}
}

# print '-'x37 . 'input:' . '-'x37 . "\n";
# print $string . "\n";
# print '-'x36 . 'output:' . '-'x37 . "\n";

my @phrases = ();
{
@phrases = &make_phrases(\@tokens);
# use Data::Dumper 'Dumper';
# print Dumper( \@phrases );
}
@tokens = ();

# use Data::Dumper 'Dumper';

# $Data::Dumper::Deparse = 1;
# $Data::Dumper::Terse   = 1;
# $Data::Dumper::Indent  = 0;
# print Data::Dumper::Dumper(\@phrases);

foreach my $phrase ( @phrases )
{
	$phrase -> exec();
#	print &Data::Dumper::Dumper( $phrase -> exec() );
#	if( my $r = $phrase -> exec() )
#	{
#		if( $r -> isa( 'Dorq::link' ) )
#		{
#			$r = $r -> val();
#		}

#		print $r -> val() . "\n";
#	}
}

}

sub get_category
{
	my ( $word, $chars ) = @_;
	my @ids = ();

SCAN_CATEGORIES_TABLE:
	foreach my $id ( keys %table )
	{
		my $sref = ref( my $spec = $table{ $id } );

		if( $sref eq 'Regexp' )
		{
			if( $word =~ m/$spec/ )
			{
#			warn $word, $id;
				push @ids, $id;
				last;
			}

		} elsif( $sref eq 'HASH' )
		{
			my ( $from_re, $to_re ) = @$spec{ 'from_re', 'to_re' };

			if( ( ref( $from_re ) eq 'Regexp' ) and ( ref( $to_re ) eq 'Regexp' ) )
			{
				my ( $trans_from, $trans_to ) = map{ ( ( ref( $_ ) eq 'CODE' ) ? $_ : sub{ return shift } ) } @$spec{ 'trans_from', 'trans_to' };

				my $word = $word;

				$word = $trans_from -> ( $word );
# warn $id . ':' . $word . ':' . $from_re if $word =~ m/^let/;
				if( $word =~ m/$from_re/ )
				{
					my $lword = $word;

					unless( $spec -> { 'no_extra_stop' } )
					{
						my $cword = $word;

						chop $cword;

						next SCAN_CATEGORIES_TABLE if $trans_to -> ( $cword ) =~ m/$to_re/;
					}

#					unless( $trans_to -> ( $lword ) =~ m/$to_re/ )
					{
						my $flag = 0;

						for( my $i = 0; $i < scalar( @$chars ); $lword .= $chars -> [ $i ], ++$i )
						{
							if( $trans_to -> ( $lword ) =~ m/$to_re/ )
							{
								$flag = 1;
#								warn 'FLAG: ' . $lword;

							} elsif( $flag )
							{
								chop $lword;
#								warn 'K: ' . $lword;
								last;
							}
							# warn $id . ':' .  $lword . ':' . $to_re if $lword =~ m/^let/;
							# $lword .= $chars -> [ $i ];
						}
					}

					if( ref( my $after = $spec -> { 'after' } ) eq 'CODE' )
					{
						$after -> ( $lword, $chars );
					}

#warn $id . ':' . $lword . ':' . $to_re if $lword =~ m/^let/;
					if( $trans_to -> ( $lword ) =~ m/$to_re/ )
					{
						push @ids, $id;
						last;
					}
				}
			}
		}
	}
# warn join(',',@ids) if scalar( @ids ) > 1;
# warn join(',',@ids), $word;
	return ( ( scalar( @ids ) == 1 ) ? shift( @ids ) : undef );
}

sub make_phrases
{
my $tokens = shift;
my @output = ();
my @phrase = ();
my @container = ();
my $parens = 0;
# print Dumper( $tokens );
for( my $i = 0; $i < scalar( @$tokens ); ++$i )
{
#	unless( ref( $tokens -> [ $i ] ) eq 'HASH' )
#	{
#		use Data::Dumper 'Dumper';
#		print Dumper( $tokens );
#		print $tokens -> [ $i ] . "\n";
#	}

	my ( $type, $value ) = %{ $tokens -> [ $i ] };

	if( $type eq 'parens_open' )
	{
		++$parens;
		push @container, $tokens -> [ $i ] if $parens > 1;
		next;

	} elsif( $type eq 'parens_close' )
	{
		push @container, $tokens -> [ $i ] if $parens > 1;
		--$parens;

		if( $parens == 0 )
		{
#		use Data::Dumper 'Dumper';
#		print Dumper( \@container );
#		print Dumper( &make_phrases( \@container ) );
		push @container, { separator => ';' };
			push @phrase, &make_phrases( \@container );
			@container = ();
		}

		next;
	}

	if( $parens > 0 )
	{
		push @container, $tokens -> [ $i ];

	} elsif( $parens == 0 )
	{
		my $pkg = sprintf( 'Dorq::%s', join( '::', split( /_/, $type ) ) );

		if( $type eq 'type_string' )
		{
			$value =~ s/^\"|\"$//g;
		}

		push @phrase, $pkg -> new( \$value );

	} else
	{
		die 'Unmatched parenthesis';
	}

	if( ( $parens == 0 ) and ( ( $type eq 'separator' ) or ( $type eq 'separator2' ) ) )
	{
		pop @phrase;

		my $pkg = 'Dorq::code';

		push @output, $pkg -> new( \( my $dummy = [ @phrase ] ) );# if scalar( @phrase ) > 0;
		@phrase = ();
	}
}
die 'Unmatched parenthesis' unless $parens == 0;
{
		my $pkg = 'Dorq::code::block';

return $pkg -> new( \\@output );
}
}

-1;

