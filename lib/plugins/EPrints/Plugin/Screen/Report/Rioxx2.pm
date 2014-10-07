package EPrints::Plugin::Screen::Report::Rioxx2;

use EPrints::Plugin::Screen::Report;
our @ISA = ( 'EPrints::Plugin::Screen::Report' );

use strict;

#
# A simple Report
#

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{datasetid} = 'eprint';
	$self->{custom_order} = '-title/creators_name';
	$self->{appears} = [];

	return $self;
}

sub can_be_viewed
{
	my( $self ) = @_;

	return 0 if( !$self->SUPER::can_be_viewed );

# you can limit who can see this report:
#	return $self->allow( 'report/example' );
	
	return 1;
}

# Filters allow to select a sub-set of the data objects
sub filters
{
	my( $self ) = @_;

	my @filters = @{ $self->SUPER::filters || [] };

	# Must be in the Live Archive
	push @filters, { meta_fields => [ 'eprint_status' ], value => 'archive', match => 'EX' };

	# Must have been published in 2002
	#push @filters, { meta_fields => [ 'date' ], value => '2000', match => 'EX' };
	
	return \@filters;
}

sub ajax_eprint
{
	my( $self ) = @_;

	my $repo = $self->repository;

	my $json = { data => [] };

	$repo->dataset( "eprint" )
	->list( [$repo->param( "eprint" )] )
	->map(sub {
		(undef, undef, my $eprint) = @_;

		return if !defined $eprint; # odd

		my $frag = $eprint->render_citation_link;
		push @{$json->{data}}, { 
			datasetid => $eprint->dataset->base_id, 
			dataobjid => $eprint->id, 
			summary => EPrints::XML::to_string( $frag ),
#			grouping => sprintf( "%s", $eprint->value( SOME_FIELD ) ),
			problems => [ $self->validate_dataobj( $eprint ) ],
		};
	});

	print $self->to_json( $json );
}


sub get_related_objects
{
	my( $plugin, $dataobj ) = @_;

	my $repository = $plugin->{repository};

	my $objects = {
		$dataobj->dataset->confid => $dataobj,
	};

	# Add your own rules here to include other data-obj (perhaps you need the Users, Funders etc to generate your reports...)

	return $objects;
}

1;
