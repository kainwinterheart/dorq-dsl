use strict;
use utf8;

package Dorq::Launcher;

use Perl6::Slurp '&slurp';

sub run_file
{
	return &Dorq::Runner::eval_string( scalar &slurp( shift ) );
}

-1;

