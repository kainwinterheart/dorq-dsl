use strict;
use utf8;

package Dorq::builtins;

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

-1;

