
=pod

The RIOXX 2.0 application profile

A representation of the RIOXX 2.0 application profile as defined by http://rioxx.net/v2-0-beta-1/

The following properties are mandatory and taken directly from the application profile:

name - element name
rioxx2_required - one of "optional", "recommended" or "mandatory"
rioxx2_ns - element namespace

Additional optional properties can be used to define exactly how an element's value should be derived and/or validated

rioxx2_value - subroutine that given an eprint and document returns the element's value
rioxx2_validate - subroutine that given

=cut

use EPrints::RIOXX2::Utils;

push @{ $c->{rioxx2}->{profile} },

{
	name => "rioxx2_coverage",
	rioxx2_required => "optional",
	rioxx2_ns => "dc",
},

{
	name => "rioxx2_description",
	rioxx2_required => "recommended",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[0]->value( "abstract" ) },
	rioxx2_validate => "rioxx2_validate_description"
},

{
	name => "rioxx2_format",
	rioxx2_required => "recommended",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[1] && $_[1]->value( "mime_type" ) },
},

{
	name => "rioxx2_identifier",
	rioxx2_required => "mandatory",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[1] && $_[1]->get_url },
},

{
	name => "rioxx2_language",
	rioxx2_required => "mandatory",
	rioxx2_ns => "dc",
	rioxx2_value => sub { ( $_[1] && $_[1]->value( "language" ) ) || $_[0]->repository->config( "defaultlanguage" ) },
},

{
	name => "rioxx2_publisher",
	rioxx2_required => "recommended",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[0]->value( "publisher" ) },
},

{
	name => "rioxx2_relation",
	rioxx2_required => "optional",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[0]->value( "related_url_url" ) },
	rioxx2_validate => "rioxx2_validate_relation"
},

{
	name => "rioxx2_source", 
	rioxx2_required => sub { ( $_[0]->get_type eq "article" || $_[0]->get_type eq "book_section" || $_[0]->get_type eq "conference_item" ) ? "mandatory" : "optional" },
	rioxx2_ns => "dc",
	rioxx2_value => "rioxx2_value_source",
},

{
	name => "rioxx2_subject",
	rioxx2_required => "recommended",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[0]->value( "subjects" ) },
},

{
	name => "rioxx2_title",
	rioxx2_required => "mandatory",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[0]->value( "title" ) },
},

{
	name => "rioxx2_dateAccepted",
	rioxx2_required => "mandatory",
	rioxx2_ns => "dcterms",
},

{
	name => "rioxx2_free_to_read",
	rioxx2_required => "optional",
	rioxx2_ns => "niso",
	rioxx2_value => "rioxx2_value_free_to_read",
	rioxx2_validate => "rioxx2_validate_free_to_read"
},

# TODO rioxx2_value: derive from document.license + document.date_embargo
{
	name => "rioxx2_license_ref",
	rioxx2_required => "mandatory",
	rioxx2_ns => "niso",
	rioxx2_validate => "rioxx2_validate_license_ref"
},

{
	name => "rioxx2_apc",
	rioxx2_required => "optional",
	rioxx2_ns => "rioxxterms",
},

{
	name => "rioxx2_author",
	rioxx2_required => "mandatory",
	rioxx2_ns => "rioxxterms",
	rioxx2_value => "rioxx2_value_author",
},

{
	name => "rioxx2_contributor",
	rioxx2_required => "optional",
	rioxx2_ns => "rioxxterms",
	rioxx2_value => "rioxx2_value_contributor",
},

{
	name => "rioxx2_project",
	rioxx2_required => "mandatory",
	rioxx2_ns => "rioxxterms",
	rioxx2_value => "rioxx2_value_project",
	rioxx2_validate => "rioxx2_validate_project"
},

{
	name => "rioxx2_publication_date",
	rioxx2_required => "optional",
	rioxx2_ns => "rioxxterms",
	rioxx2_value => sub { ( !$_[0]->is_set( "date_type" ) || $_[0]->value( "date_type" ) eq "published" ) && $_[0]->value( "date" ) },
},

{
	name => "rioxx2_type",
	rioxx2_required => "mandatory",
	rioxx2_ns => "rioxxterms",
	rioxx2_value => sub { $_[0]->repository->config( "rioxx2", "type_map", $_[0]->get_type ) || "other" },
},

{
	name => "rioxx2_version",
	rioxx2_required => "mandatory",
	rioxx2_ns => "rioxxterms",
	rioxx2_value => sub { $_[1] && $_[1]->repository->config( "rioxx2", "content_map", $_[1]->value( "content" ) ) || "NA" },
},

# TODO check id_number contains a DOI
# TODO rioxx2_validate: must be a HTTP URL
# this is more of a conditional mandatory rather than a mandatory i.e. if there is a DOI it is manadatory
# we could therefore say that if it is published and an article then it is manadtory.
# could probably provide an override for this field
{
	name => "rioxx2_version_of_record",
	rioxx2_required => "mandatory",
	rioxx2_ns => "rioxxterms",
	rioxx2_value =>"rioxx2_value_version_of_record",
	rioxx2_validate => "rioxx2_validate_version_of_record"
},

;

for( @{ $c->{rioxx2}->{profile} } )
{
	$_->{type} = "rioxx2"; # virtual field
	$c->add_dataset_field( "eprint", $_ );
}

=pod

Map eprint deposit type to RIOXX type element

=cut

$c->{rioxx2}->{type_map} = {
	article		=> 'Journal Article/Review',
	book_section	=> 'Book chapter',
	monograph	=> 'Monograph',
	conference_item	=> 'Conference Paper/Proceeding/Abstract',
	book		=> 'Book',
	thesis		=> 'Thesis',
};

=pod

Map document content type to RIOXX2 version element

=cut

$c->{rioxx2}->{content_map} = {
	draft		=> "AO",
	submitted	=> "SMUR",
	accepted	=> "AM",
	published	=> "P",
};

=pod

Define RIOXX fields that can be overridden

Allows any of the fields defined in the profile above to be entered manually

* allow user to override the derived value
* allow user to enter a value where no value can be derived (ie. no field in eprints schema)

Use same name as profile but postfix "_input"

=cut

push @{ $c->{rioxx2}->{overrides} },

{
	name => "rioxx2_coverage_input",
	type => "text",
	multiple => 1,
	show_in_html => 0,
},

{
	name => "rioxx2_language_input",
	type => "namedset",
	input_rows => 1,
	set_name => "languages",
	multiple => 1,
	show_in_html => 0,
},

{
	name => "rioxx2_dateAccepted_input",
	type => "date",
	min_resolution => "year",
	show_in_html => 0,
},

{
	name => "rioxx2_free_to_read_input",
	type => "compound",
	show_in_html => 0,
	fields => [
		{ sub_name => "free_to_read", type => "set", options => [ "Y" ] },
		{ sub_name => "start_date", type => "date", min_resolution => "day" },
		{ sub_name => "end_date", type => "date", min_resolution => "day" }
	]
},

{
	name => "rioxx2_license_ref_input",
	type => "compound",
	show_in_html => 0,
	fields => [
		{ sub_name => "license_ref", type => "url", input_cols => "45" },
		{ sub_name => "start_date", type => "date" }
	],
},

{
	name => "rioxx2_apc_input",
	type => "set",
	show_in_html => 0,
	options => [ "paid", "partially waived", "fully waived", "not charged", "not required", "unknown" ] 
},

{
	name => "rioxx2_project_input",
	type => "compound",
	show_in_html => 0,
	fields => [
		{ sub_name => "project", type => "text", input_cols => "25" },
		{ sub_name => "funder_name", type => "text", input_cols => "25" },
		{ sub_name => "funder_id", type => "url", input_cols => "25" }
	],
	multiple => 1,
	input_lookup_url => "/cgi/users/lookup/rioxx2_project",
	input_lookup_params => "file=funderNames",
},

{
	name => "rioxx2_publication_date_input",
	type => "text",
	show_in_html => 0,
},

{
	name => "rioxx2_type_input",
	type => "set",
	show_in_html => 0,
	options => [ 
		"Book",
		"Book chapter",
		"Book edited",
		"Conference Paper/Proceeding/Abstract",
		"Journal Article/Review",
		"Manual/Guide",
		"Monograph",
		"Policy briefing report",
		"Technical Report",
		"Technical Standard",
		"Thesis",
		"Other",
		"Consultancy Report",
		"Working paper"
	],
	multiple => 1
},

{
	name => "rioxx2_version_input",
	type => "set",
	show_in_html => 0,
	options => [qw( AO SMUR AM P VoR CVoR EVoR NA )],
},

;

for( @{ $c->{rioxx2}->{overrides} } )
{
	$c->add_dataset_field( "eprint", $_ );
}

=pod

Subroutines for deriving values for RIOXX2 elements

Arguments:

eprint
document

=cut

$c->{rioxx2_value_source} = sub {
	my ( $eprint ) = @_;

	for( qw( issn isbn publication book_title event_title ) )
	{
		next unless $eprint->is_set( $_ );
		return $eprint->value( $_ );
	}
};

$c->{rioxx2_value_free_to_read} = sub {
	my( $eprint, $document ) = @_;

	return undef unless $document;
	return { free_to_read => 1 } if $document->is_set( "security" ) && $document->value( "security" ) eq "public";
	return { free_to_read => 1, start_date => $document->value( "date_embargo" ) } if $document->is_set( "date_embargo" );
};

$c->{rioxx2_value_author} = sub {
	my( $eprint ) = @_;

	my @authors;
	for( @{ $eprint->value( "creators_name" ) } )
	{
		push @authors, EPrints::Utils::make_name_string( $_ );
	}
	push @authors, @{ $eprint->value( "corp_creators" ) };

	return \@authors;
};

$c->{rioxx2_value_contributor} = sub {
	my( $eprint ) = @_;

	my @contributors;
	for( @{ $eprint->value( "editors_name" ) }, @{ $eprint->value( "contributors_name" ) } )
	{
		push @contributors, EPrints::Utils::make_name_string( $_ );
	}

	return \@contributors;
};

$c->{rioxx2_value_project} = sub {
	my( $eprint ) = @_;

	return unless $eprint->is_set( "funders" ) && $eprint->is_set( "projects" );

	# attempt to give every project a funder (and vice versa)
	my @p = @{ $eprint->value( "projects" ) };
	my @f = @{ $eprint->value( "funders" ) };

	while( scalar @p < scalar @f )
	{
		# fewer projects than funders - top up project list by repeating last element
		push @p, $p[$#p];
	}

	my @projects;
	for( my $i = 0; $i < scalar @p; $i++ )
	{
		push @projects, {
			project => $p[$i],
			# if fewer funders than projects, use the last funder
			funder_name => ( $i > $#f ? $f[$#f] : $f[$i] ),
		};
	}
	return \@projects;
};

$c->{rioxx2_value_version_of_record} = sub {
	my( $eprint ) = @_;

	my $value;
	foreach my $field ( qw( doi id_number ) )
	{
		$value = $eprint->value( $field ) if $eprint->exists_and_set( $field );
		last if $value;
	}
	return unless $value;

	# must be a HTTP URI
	return $value if $value =~ /^http/;

	# if value looks like a DOI convert to HTTP form..
	if( $value =~ /^(doi:)?10\..+\/.+/ )
	{
		$value =~ s/^doi://;
		return "http://dx.doi.org/$value";
	}

	# ..otherwise give up
	return;
};

=pod

Subroutines for validating RIOXX2 elements

Arguments

repo
value
eprint

=cut

$c->{rioxx2_validate_description} = sub {
	my( $repo, $value, $eprint ) = @_;

	if( EPrints::RIOXX2::Utils::contains_markup( $value ) )
	{
		return $repo->html_phrase( "rioxx2_validate_rioxx2_description:contains_markup" );
	}
};

$c->{rioxx2_validate_relation} = sub {
	my( $repo, $value, $eprint ) = @_;

	my @problems;
	for( @$value )
	{
		unless( EPrints::RIOXX2::Utils::is_http_uri( $value ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_relation:not_http_uri" );
		}
	}
	return @problems;
};

$c->{rioxx2_validate_free_to_read} = sub {
	my( $repo, $value, $eprint ) = @_;

	my @problems;
	unless( EPrints::Utils::is_set( $value->{free_to_read} ) )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_free_to_read:not_done_part_free_to_read" );
	}
	if( $value->{start_date} && !EPrints::RIOXX2::Utils::is_iso_8601_date( $value->{start_date} ) )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_free_to_read_start_date:not_iso_8601_date" );
	}
	if( $value->{end_date} && !EPrints::RIOXX2::Utils::is_iso_8601_date( $value->{end_date} ) )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_free_to_read_end_date:not_iso_8601_date" );
	}
	return @problems;
};

$c->{rioxx2_validate_license_ref} = sub {
	my( $repo, $value, $eprint ) = @_;

	my @problems;	
	unless( EPrints::Utils::is_set( $value->{license_ref} ) )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_license_ref:not_done_part_license_ref" );
	}
	if( $value->{license_ref} && !EPrints::RIOXX2::Utils::is_http_uri( $value->{license_ref} ) )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_license_ref:not_http_uri" );
	}
	unless( EPrints::Utils::is_set( $value->{start_date} ) )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_license_ref:not_done_part_start_date" );
	}
	if( $value->{start_date} && !EPrints::RIOXX2::Utils::is_iso_8601_date( $value->{start_date} ) )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_license_ref:not_iso_8601_date" );
	}
	return @problems;
};

$c->{rioxx2_validate_project} = sub {
	my( $repo, $value, $eprint ) = @_;

	my @problems;
	for( @$value )
	{
		unless( EPrints::Utils::is_set( $_->{project} ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_done_part_project" );
		}
		if( $_->{funder} && !EPrints::RIOXX2::Utils::is_valid_funder( $_->{funder} ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_valid_funder" );
		}
		if( $_->{funder_id} && !EPrints::RIOXX2::Utils::is_http_uri( $_->{funder_id} ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_http_uri" );
		}
	}
	return @problems;
};

$c->{rioxx2_validate_version_of_record} = sub {
	my( $repo, $value, $eprint ) = @_;

	unless( EPrints::RIOXX2::Utils::is_http_uri( $value ) )
	{
		return $repo->html_phrase( "rioxx2_validate_rioxx2_version_of:not_http_uri" );
	}
};

# Enable core RIOXX2 plugins
$c->{plugins}{'Export::RIOXX2'}{params}{disable} = 0;
$c->{plugins}{"Screen::EPrint::RIOXX2"}{params}{disable} = 0;
$c->{plugins}{'InputForm::Component::Field::Rioxx2'}{params}{disable} = 0;
