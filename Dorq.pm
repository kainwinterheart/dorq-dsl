use strict;
use utf8;

package Dorq;

require Exporter;

our @ISA = ( 'Exporter' );

our @EXPORT = ( 'run' );

our $VERSION = 0.01;

use Dorq::All;

sub run
{
	my @a = @_;

	foreach my $iname ( @a )
	{
		chomp $iname;

		&Dorq::Launcher::run_file( $iname );
	}
}

