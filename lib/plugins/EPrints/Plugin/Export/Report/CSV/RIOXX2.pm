package EPrints::Plugin::Export::Report::CSV::RIOXX2;

use EPrints::Plugin::Export::Report::CSV;
our @ISA = ( "EPrints::Plugin::Export::Report::CSV" );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{name} = "RIOXX2 CSV";
	$self->{accept} = [ 'report/rioxx2-articles', ];
	$self->{advertise} = 1;
	return $self;
}


1;
