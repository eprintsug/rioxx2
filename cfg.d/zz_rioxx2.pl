
=pod

The RIOXX 2.0 application profile

A representation of the RIOXX 2.0 application profile as defined by http://rioxx.net/v2-0-final/

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
	name => "rioxx2_free_to_read",
	rioxx2_required => "optional",
	rioxx2_ns => "ali",
	rioxx2_value => "rioxx2_value_free_to_read",
	rioxx2_validate => "rioxx2_validate_free_to_read"
},

{
	name => "rioxx2_license_ref",
	rioxx2_required => "mandatory",
	rioxx2_ns => "ali",
	rioxx2_value => "rioxx2_value_license_ref",
	rioxx2_validate => "rioxx2_validate_license_ref"
},

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
	rioxx2_validate => "rioxx2_validate_description",
	show_in_html => 0,
},

{
	name => "rioxx2_format",
	rioxx2_required => "recommended",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[1] && $_[1]->value( "mime_type" ) },
	show_in_html => 0,
},

{
	name => "rioxx2_identifier",
	rioxx2_required => "mandatory",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[1] && $_[1]->get_url },
	show_in_html => 0,
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
	show_in_html => 0,
},

{
	name => "rioxx2_relation",
	rioxx2_required => "optional",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[0]->value( "related_url_url" ) },
	rioxx2_validate => "rioxx2_validate_relation",
	show_in_html => 0,
},

{
	name => "rioxx2_source", 
	rioxx2_required => sub { ( $_[0]->get_type eq "article" || $_[0]->get_type eq "book_section" || $_[0]->get_type eq "conference_item" ) ? "mandatory" : "optional" },
	rioxx2_ns => "dc",
	rioxx2_value => "rioxx2_value_source",
	show_in_html => 0,
},

{
	name => "rioxx2_subject",
	rioxx2_required => "recommended",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[0]->value( "subjects" ) },
	show_in_html => 0,
},

{
	name => "rioxx2_title",
	rioxx2_required => "mandatory",
	rioxx2_ns => "dc",
	rioxx2_value => sub { $_[0]->value( "title" ) },
	show_in_html => 0,
},

{
	name => "rioxx2_dateAccepted",
	rioxx2_required => "mandatory",
	rioxx2_ns => "dcterms",
	rioxx2_validate => "rioxx2_validate_dateAccepted",
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
	show_in_html => 0,
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
	rioxx2_value => sub { $_[1] && $_[1]->repository->config( "rioxx2", "content_map", $_[1]->value( "content" ) || "" ) || "NA" },
},

{
	name => "rioxx2_version_of_record",
	rioxx2_required => "recommended",
	rioxx2_ns => "rioxxterms",
	rioxx2_value =>"rioxx2_value_version_of_record",
	rioxx2_validate => "rioxx2_validate_version_of_record",
	show_in_html => 0,
},

;

for( @{ $c->{rioxx2}->{profile} } )
{
	$_->{type} = "RIOXX2"; # virtual field
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
	published	=> "VoR",
};

=pod

Map document license to RIOXX2 license_ref url
It is possible that the URLs may need to be changed to the "legal Code" rather than the "details"

=cut

$c->{rioxx2}->{license_map} = {
	cc_by_nd	=> "http://creativecommons.org/licenses/by-nd/4.0",
	cc_by		=> "http://creativecommons.org/licenses/by/4.0",
	cc_by_nc	=> "http://creativecommons.org/licenses/by-nc/4.0",
	cc_by_nc_nd	=> "http://creativecommons.org/licenses/by-nc-nd/4.0",
	cc_by_nc_sa	=> "http://creativecommons.org/licenses/by-nd-sa/4.0",
	cc_by_sa	=> "http://creativecommons.org/licenses/by-sa/4.0",
	cc_public_domain=> "http://creativecommons.org/publicdomain/zero/1.0/legalcode",
	cc_gnu_gpl	=> "http://www.gnu.org/licenses/gpl.html",
	cc_gnu_lgpl	=> "http://www.gnu.org/licenses/lgpl.html",
};


=pod

Select most appropriate document from eprint

=cut

$c->{rioxx2}->{select_document} = sub {
	my( $eprint ) = @_;

	my @docs = $eprint->get_all_documents;

	# simple cases
	return unless scalar @docs;
	return $docs[0] if scalar @docs == 1;

	# prefer published, accepted and submitted versions over anything else
	my %pref = (
		published => 3,
		accepted => 2,
		submitted => 1,
	);

	my @ordered = sort {
		($pref{$b->value( "content" )||""}||0) <=> ($pref{$a->value( "content" )||""}||0)
	} @docs;

	return $ordered[0] if $ordered[0]->is_set( "content" );
	
	# prefer text documents
	for( @docs )
	{
		return $_ if $_->value( "format" ) eq "text";
	}

	return $docs[0];
	

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
	sql_index => 0,
},

{
	name => "rioxx2_language_input",
	type => "namedset",
	input_rows => 1,
	set_name => "languages",
	multiple => 1,
	show_in_html => 0,
	sql_index => 0,
},

{
	name => "rioxx2_dateAccepted_input",
	type => "date",
	min_resolution => "day",
	show_in_html => 0,
	sql_index => 0,
},

{
	name => "rioxx2_free_to_read_input",
	type => "compound",
	show_in_html => 0,
	fields => [
		{ sub_name => "free_to_read", type => "set", options => [ "Yes" ] },
		{ sub_name => "start_date", type => "date", min_resolution => "day" },
		{ sub_name => "end_date", type => "date", min_resolution => "day" }
	],
	sql_index => 0,
},

{
	name => "rioxx2_license_ref_input",
	type => "compound",
	show_in_html => 0,
	fields => [
		{ sub_name => "license_ref", type => "url", input_cols => "45" },
		{ sub_name => "start_date", type => "date" }
	],
	sql_index => 0,
},

{
	name => "rioxx2_apc_input",
	type => "set",
	show_in_html => 0,
	options => [ "paid", "partially waived", "fully waived", "not charged", "not required", "unknown" ],
	sql_index => 0,
},

{
	name => "rioxx2_author_input",
	type => "compound",
	show_in_html => 0,
	fields => [
		{ sub_name => "author", type => "text", input_cols => "35" },
		{ sub_name => "id", type => "url", input_cols => "35" }
	],
	multiple => 1,
	input_lookup_url => "/cgi/users/lookup/rioxx2_orcid",
	sql_index => 0,
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
	sql_index => 0,
},

{
	name => "rioxx2_publication_date_input",
	type => "text",
	show_in_html => 0,
	sql_index => 0,
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
	multiple => 1,
	sql_index => 0,
},

{
	name => "rioxx2_version_input",
	type => "set",
	show_in_html => 0,
	options => [qw( AO SMUR AM P VoR CVoR EVoR NA )],
	sql_index => 0,
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
	return undef;
};

$c->{rioxx2_value_free_to_read} = sub {
	my( $eprint, $document ) = @_;

	return undef unless $document;
	return { free_to_read => "Yes" } if $document->is_set( "security" ) && $document->value( "security" ) eq "public";
	
	return { free_to_read => "Yes", start_date => EPrints::RIOXX2::Utils::get_embargo_lapse_date( $document->value( "date_embargo" ) )} if $document->is_set( "date_embargo" );

	return undef;
};

$c->{rioxx2_value_license_ref} = sub {
	my( $eprint, $document ) = @_;

	return undef unless $document;
	return undef unless $document->is_set( "license" );
	my $license = $document->repository->config( "rioxx2", "license_map", $document->value( "license" ) ); 
	return undef unless $license;

	my $start_date = $eprint->value( "date" ) if ( !$eprint->is_set( "date_type" ) || $eprint->value( "date_type" ) =~ m/^published/ ); 
	$start_date = EPrints::RIOXX2::Utils::get_embargo_lapse_date( $document->value( "date_embargo" ) ) if $document->is_set( "date_embargo" );
	return { license_ref => $license, start_date => $start_date };
};


$c->{rioxx2_value_author} = sub {
	my( $eprint ) = @_;

	my @authors;
    my $orcid_support_installed = 0;

    $orcid_support_installed = 1 if(EPrints::Utils::is_set($c->{plugins}{"Orcid"}) && $c->{plugins}{"Orcid"}{params}{disable} == 0);

	for( @{ $eprint->value( "creators" ) } )
	{   
        my $creator_data = { author => EPrints::Utils::make_name_string( $_->{name} ) };
        # Add orcid if available not required if orcid_support is installed 
        # normalisation from orcid_support https://github.com/eprints/orcid_support
        if( $orcid_support_installed == 0 && 
            EPrints::Utils::is_set($_->{orcid}) && 
            $_->{orcid} =~ m/\b(\d{4})\-?(\d{4})\-?(\d{4})\-?(\d{3}(?:\d|X))/ )
        {
            my $id = "$1-$2-$3-$4";
            $creator_data->{id} = "https://orcid.org/$id";
        }

		push @authors, $creator_data;
	}

	foreach my $corp ( @{ $eprint->value( "corp_creators" ) } )
	{
		my $entry = {};
		$entry->{name} = $corp;
		push @authors, { author => $corp };
	}

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

	# if value looks like a DOI convert to HTTP form..
	if( $value =~ /^(doi:)?10\..+\/.+/ )
	{
		$value =~ s/^doi://;
		return "https://doi.org/$value";
	}

	return $value;
};

=pod

Subroutines for validating RIOXX2 elements

Arguments

repo
value
eprint

=cut

$c->{rioxx2_validate_dateAccepted} = sub {
	my( $repo, $value, $eprint ) = @_;

	if( $value && !EPrints::RIOXX2::Utils::is_iso_8601_date( $value ) )
	{
	    return $repo->html_phrase( "rioxx2_validate_rioxx2_dateAccepted:not_iso_8601_date" );
	}

    return;
};

$c->{rioxx2_validate_description} = sub {
	my( $repo, $value, $eprint ) = @_;

	if( EPrints::RIOXX2::Utils::contains_markup( $value ) )
	{
		return $repo->html_phrase( "rioxx2_validate_rioxx2_description:contains_markup" );
	}

	return;
};

$c->{rioxx2_validate_relation} = sub {
	my( $repo, $value, $eprint ) = @_;

	my @problems;
	for( @$value )
	{
		unless( EPrints::RIOXX2::Utils::is_http_or_https_uri( $value ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_relation:not_http_uri" );
		}
	}
	return @problems;
};

$c->{rioxx2_validate_free_to_read} = sub {
	my( $repo, $value, $eprint ) = @_;

	my @problems;
	if ( ref($value) ne 'HASH' )
        {
                push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_free_to_read:not_done_part_free_to_read" );
                return @problems;
        }
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
	if( $value->{license_ref} && !EPrints::RIOXX2::Utils::is_http_or_https_uri( $value->{license_ref} ) )
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
	foreach my $entry ( @$value )
	{
		my $project = $entry->{project};
		my $funder_name = $entry->{funder_name};
		my $funder_id = $entry->{funder_id};
		unless( EPrints::Utils::is_set( $project ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_done_part_project" );
		}
		unless( EPrints::Utils::is_set( $funder_name ) || EPrints::Utils::is_set( $funder_id ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_done_part_funder" );
		}

        	my $funder_lookup = EPrints::RIOXX2::Utils::get_funder_lookup( $repo ) if $funder_name; 

		if( $funder_name && !EPrints::RIOXX2::Utils::is_valid_funder_name( $funder_name, $funder_lookup ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_valid_funder" );
		}
		if( $funder_id && !EPrints::RIOXX2::Utils::is_http_or_https_uri( $funder_id ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:not_http_uri" );
		}
		if( $funder_id && $funder_name && !EPrints::RIOXX2::Utils::is_valid_funder_id( $funder_id, $funder_name, $funder_lookup ) )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate_rioxx2_project:funder_name_id_do_not_match" );
		}
	}
	return @problems;
};

$c->{rioxx2_validate_version_of_record} = sub {
	my( $repo, $value, $eprint ) = @_;

	unless( EPrints::RIOXX2::Utils::is_http_or_https_uri( $value ) )
	{
		return $repo->html_phrase( "rioxx2_validate_rioxx2_version_of_record:not_http_uri" );
	}

	return;
};

$c->{fundref_csv_file} = $c->{"config_path"}."/autocomplete/funderNames";

# Enable core RIOXX2 plugins
$c->{plugins}{'Export::RIOXX2'}{params}{disable} = 0;
$c->{plugins}{"Screen::EPrint::RIOXX2"}{params}{disable} = 0;
$c->{plugins}{'InputForm::Component::Field::RIOXX2'}{params}{disable} = 0;
# Enable optional RIOXX2 plugins for reporting framework (https://github.com/eprints/reports)
$c->{plugins}{"Screen::Report::RIOXX2"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2014"}{params}{disable} = 0;
$c->{plugins}{"Export::Report::CSV::RIOXX2"}{params}{disable} = 0;

push @{$c->{user_roles}->{admin}}, qw{ +report/rioxx2 };
push @{ $c->{user_roles}->{editor} }, qw{ +eprint/rioxx2 };
push @{ $c->{user_roles}->{admin} }, qw{ +eprint/rioxx2 };
