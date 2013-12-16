use strict;
use utf8;

package Dorq::builtins;

sub true
{
	return Dorq::code::block::builtin -> new( \sub
	{
		return Dorq::type::bool -> new( \( my $dummy = 1 ) );
	} );
}

sub false
{
	return Dorq::code::block::builtin -> new( \sub
	{
		return Dorq::type::bool -> new( \( my $dummy = 0 ) );
	} );
}

sub print
{
	return Dorq::code::block::builtin -> new( \sub
	{
		print $_[ 1 ] -> get( Dorq::var -> new( \(my $dummy = '$str' ) ) ) -> val() -> cast_string() -> val();

		return Dorq::type::undef -> new( \( my $dummy = undef ) );
	} );
}

sub E
{
	return Dorq::code::block::builtin -> new( \sub
	{
		return Dorq::type::string -> new( \( my $dummy = eval( 'qq{' . $_[ 1 ] -> get( Dorq::var -> new( \(my $dummy = '$str' ) ) ) -> val() -> cast_string() -> val() .'}' ) ) );
	} );
}

sub Dump
{
	return Dorq::code::block::builtin -> new( \sub
	{
		require Data::Dumper;

		print Data::Dumper::Dumper( $_[ 1 ] -> get( Dorq::var -> new( \(my $dummy = '$val' ) ) ) -> val() ), "\n";

		return Dorq::type::undef -> new( \( my $dummy = undef ) );
	} );
}

sub ruleset
{
	return Dorq::code::block::builtin -> new( \sub
	{
		my $ctx = $_[ 1 ];

		my $set = $ctx -> get( Dorq::var -> new( \( my $dummy = '$set' ) ) ) -> val();

		die '$set should be an array' unless $set -> isa( 'Dorq::array' );

		my $default = undef;

		{
			my $default_name = Dorq::var -> new( \( my $dummy = '$default' ) );

			if( $ctx -> has( $default_name ) )
			{
				$default = $ctx -> get( $default_name ) -> val();

				die '$default should be a lambda' unless $default -> isa( 'Dorq::lambda' );
			}
		}

		foreach my $rule ( @{ $set -> { 'list' } or [] } )
		{
			$rule = $$rule;

			die 'each rule should be an array' unless $rule -> isa( 'Dorq::array' );

			die 'each rule should have exactly two items' if $rule -> size() -> val() != 2;

			my $cond = ${ $rule -> { 'list' } -> [ 0 ] };
			my $code = ${ $rule -> { 'list' } -> [ 1 ] };

			die 'first element of each rule should be a lambda representing condition' unless $cond -> isa( 'Dorq::lambda' );
			die 'second element of each rule should be a lambda representing appropriate actions' unless $code -> isa( 'Dorq::lambda' );

			my $child_ctx = Dorq::context -> new( $ctx );

			my $result = $cond -> call( $child_ctx );

			if( $result -> isa( 'Dorq::link' ) )
			{
				$result = $result -> val();
			}

			if( $result -> isa( 'Dorq::var' ) )
			{
				$result = $result -> val();
			}

			die 'conditional lambda should return boolean value' unless $result -> isa( 'Dorq::type::bool' );

			if( $$result )
			{
				$code -> call( $child_ctx );

				$default = undef;

				last;
			}
		}

		if( defined $default )
		{
			my $child_ctx = Dorq::context -> new( $ctx );

			$default -> call( $child_ctx );
		}

		return Dorq::type::undef -> new( \( my $dummy = undef ) );
	} );
}

-1;

