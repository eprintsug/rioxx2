package EPrints::Plugin::Screen::Report::Example::ConferenceItems;

use EPrints::Plugin::Screen::Report::Example;
our @ISA = ( 'EPrints::Plugin::Screen::Report::Example' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{report} = 'example-conf-items';

	return $self;
}

sub filters
{
	my( $self ) = @_;

	my @filters = @{ $self->SUPER::filters || [] };

	push @filters, { meta_fields => [ "type" ], value => 'conference_item' };

	return \@filters;
}

1;
