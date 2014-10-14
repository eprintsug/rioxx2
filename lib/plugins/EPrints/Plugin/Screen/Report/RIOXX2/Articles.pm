package EPrints::Plugin::Screen::Report::RIOXX2::Articles;

use EPrints::Plugin::Screen::Report::RIOXX2;
our @ISA = ( 'EPrints::Plugin::Screen::Report::RIOXX2' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{report} = 'rioxx2-articles';

	return $self;
}

sub filters
{
	my( $self ) = @_;

	my @filters = @{ $self->SUPER::filters || [] };

	push @filters, { meta_fields => [ "type" ], value => 'article' };

	return \@filters;
}

1;
