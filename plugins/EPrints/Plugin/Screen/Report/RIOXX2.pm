package EPrints::Plugin::Screen::Report::RIOXX2;

use EPrints::Plugin::Screen::Report;
our @ISA = ( 'EPrints::Plugin::Screen::Report' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{datasetid} = 'eprint';
	$self->{custom_order} = '-title/creators_name';
	$self->{appears} = [];
	$self->{report} = 'rioxx2';

	return $self;
}

sub can_be_viewed
{
	my( $self ) = @_;

	return 0 if( !$self->SUPER::can_be_viewed );

	return $self->allow( 'report/rioxx2' );
}

sub filters
{
	my( $self ) = @_;

	my @filters = @{ $self->SUPER::filters || [] };

	push @filters, { meta_fields => [ 'eprint_status' ], value => 'archive', match => 'EX' };

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

		my $frag = $eprint->render_citation_link_staff;
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


sub validate_dataobj
{
	my( $self, $eprint ) = @_;

	my $repo = $self->{repository};

	my @problems;

	my @fields = grep { $_->type =~ /^RIOXX2$/ } $eprint->get_dataset->get_fields;
	foreach my $field ( @fields )
	{
		push @problems, map { EPrints::XML::to_string( $_ ) } $field->validate( $repo, $eprint->value( $field->get_name ), $eprint );
	}

	return @problems;
}

1;
