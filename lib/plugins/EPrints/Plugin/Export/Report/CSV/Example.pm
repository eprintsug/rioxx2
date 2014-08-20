package EPrints::Plugin::Export::Report::CSV::Example;

use EPrints::Plugin::Export::Report::CSV;
our @ISA = ( "EPrints::Plugin::Export::Report::CSV" );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{name} = "Example CSV";
	$self->{accept} = [ 'report/example-articles', 'report/example-conf-items' ];
	$self->{advertise} = 1;
	return $self;
}


1;
