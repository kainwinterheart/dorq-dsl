use strict;
use utf8;

package Dorq::All;

BEGIN
{
	require Carp;

	$SIG{ __DIE__ } = sub
	{
		CORE::die( ( scalar( grep{ ref } @_ ) ) ? @_ : &Carp::longmess( @_ ) );
	};
};

use Dorq::globalstate;
use Dorq::internals;
use Dorq::builtins;

use Dorq::object;

use Dorq::context;

use Dorq::op;
use Dorq::op::binary;

use Dorq::op::add;
use Dorq::op::assign;
use Dorq::op::comma;
use Dorq::op::div;
use Dorq::op::eq;
use Dorq::op::gt;
use Dorq::op::gte;
use Dorq::op::lt;
use Dorq::op::lte;
use Dorq::op::mod;
use Dorq::op::mul;
use Dorq::op::subtr;

use Dorq::type;
use Dorq::type::bool;
use Dorq::type::num;
use Dorq::type::string;
use Dorq::type::undef;

use Dorq::var;
use Dorq::link;

use Dorq::code;
use Dorq::code::recompillable;

use Dorq::code::block;

use Dorq::code::block::builtin;
use Dorq::code::block::custom;

use Dorq::code::block::array_initializer;
use Dorq::code::block::hash_initializer;

use Dorq::decl;
use Dorq::decl::array;
use Dorq::decl::fun;
use Dorq::decl::hash;
use Dorq::decl::lambda;
use Dorq::decl::var;

use Dorq::function;
use Dorq::hash;
use Dorq::lambda;
use Dorq::array;

use Dorq::method::call;

use Dorq::parens::close;
use Dorq::parens::open;

use Dorq::sqbra::close;
use Dorq::sqbra::open;

use Dorq::figbra::close;
use Dorq::figbra::open;

use Dorq::separator;
use Dorq::separator2;

use Dorq::loop::object;
use Dorq::loop::next_exc;
use Dorq::loop::last_exc;

use Dorq::Runner;
use Dorq::Launcher;

-1;

