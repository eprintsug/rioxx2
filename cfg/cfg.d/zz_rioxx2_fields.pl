# New EPrint Fields for RIOXX2

$c->{rioxx2}->{type_map} = {
	article		=> 'Journal Article/Review',
	book_section	=> 'Book chapter',
	monograph	=> 'Monograph',
	conference_item	=> 'Conference Paper/Proceeding/Abstract',
	book		=> 'Book',
	thesis		=> 'Thesis',
};

$c->{rioxx2}->{content_map} = {
	draft		=> "AO",
	submitted	=> "SMUR",
	accepted	=> "AM",
	published	=> "P",
};

# rioxx2 virtual fields

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_coverage", type => "rioxx2", rioxx2_required => "optional", rioxx2_ns => "dc", rioxx2_validate => "rioxx2_validate_coverage" });

# TODO strip HTML
# validation checks for markup and reports the tags found - that might be more appropriate than trying to strip out tags.
$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_description", type => "rioxx2", rioxx2_validate=>"rioxx2_validate_description", rioxx2_value => sub { $_[0]->value( "abstract" ) }, rioxx2_required => "recommended", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_format", type => "rioxx2", rioxx2_value => sub { $_[1] && $_[1]->value( "mime_type" ) }, rioxx2_validate=>"rioxx2_validate_mime_type", rioxx2_required => "recommended", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_identifier", type => "rioxx2", rioxx2_value => sub { $_[1] && $_[1]->get_url }, rioxx2_validate=>"rioxx2_validate_identifier", rioxx2_required => "mandatory", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_language", type => "rioxx2", rioxx2_value => sub { $_[1] && $_[1]->value( "language" ) }, rioxx2_validate=>"rioxx2_validate_language", rioxx2_required => "mandatory", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_publisher", type => "rioxx2", rioxx2_value => sub { $_[0]->value( "publisher" ) }, rioxx2_validate=>"rioxx2_validate_publisher", rioxx2_required => "recommended", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_relation", type => "rioxx2", rioxx2_value => sub { $_[0]->value( "related_url_url" ) }, rioxx2_validate=>"rioxx2_validate_relation", rioxx2_required => "optional", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_source", type => "rioxx2", rioxx2_value => "rioxx2_source", rioxx2_validate=>"rioxx2_validate_source", rioxx2_required => "mandatory", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_subject", type => "rioxx2", rioxx2_value => sub { $_[0]->value( "subjects" ) }, rioxx2_validate=>"rioxx2_validate_subject", rioxx2_required => "recommended", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_title", type => "rioxx2", rioxx2_value => sub { $_[0]->value( "title" ) }, rioxx2_validate=>"rioxx2_validate_title", rioxx2_required => "mandatory", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_dateAccepted", type => "rioxx2", rioxx2_validate=>"rioxx2_validate_dateAccepted", rioxx2_required => "mandatory", rioxx2_ns => "dcterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_free_to_read", type => "rioxx2", rioxx2_value => "rioxx2_free_to_read", rioxx2_validate=>"rioxx2_validate_free_to_read", rioxx2_required => "optional", rioxx2_ns => "tbc" }
);

$c->add_dataset_field(
	"eprint",
	# TODO rioxx2_value: derive from document.license + document.date_embargo
	# TODO rioxx2_validate: license_ref must be HTTP URL, must include start_date
	{ name => "rioxx2_license_ref", type => "rioxx2", rioxx2_validate=>"rioxx2_validate_license_ref", rioxx2_required => "mandatory", rioxx2_ns => "tbc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_apc", type => "rioxx2", rioxx2_validate=>"rioxx2_validate_apc", rioxx2_required => "optional", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_author", type => "rioxx2", rioxx2_value => "rioxx2_author", rioxx2_validate=>"rioxx2_validate_author", rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_contributor", type => "rioxx2", rioxx2_value => "rioxx2_contributor", rioxx2_validate=>"rioxx2_validate_contributor", rioxx2_required => "optional", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_project", type => "rioxx2", rioxx2_value => "rioxx2_project", rioxx2_validate=>"rioxx2_validate_project", rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_publication_date", type => "rioxx2", rioxx2_value => sub { ( !$_[0]->is_set( "date_type" ) || $_[0]->value( "date_type" ) eq "published" ) && $_[0]->value( "date" ) }, rioxx2_validate=>"rioxx2_validate_publication_date", rioxx2_required => "optional", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_type", type => "rioxx2", rioxx2_value => sub { $_[0]->repository->config( "rioxx2", "type_map", $_[0]->get_type ) || "other" }, rioxx2_validate=>"rioxx2_validate_type", rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_version", type => "rioxx2", rioxx2_value => sub { $_[1] && $_[1]->repository->config( "rioxx2", "content_map", $_[1]->value( "content" ) ) || "NA" }, rioxx2_validate=>"rioxx2_validate_version", rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	# TODO check id_number contains a DOI
	# TODO rioxx2_validate: must be a HTTP URL
	# this is more of a conditional mandatory rather than a mandatory i.e. if there is a DOI it is manadatory
	# we could therefore say that if it is published and an article then it is manadtory.
	# could probably provide an override for this field
	{ name => "rioxx2_version_of_record", type => "rioxx2", rioxx2_value =>"rioxx2_version_of_record", rioxx2_validate=>"rioxx2_validate_version_of", rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
);

# overrides

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_coverage_input", type => "text", multiple => 1, show_in_html => 0, }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_language_input", type => "namedset", input_rows => 1, set_name => "languages", multiple => 1, required => 1, show_in_html => 0,}
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_dateAccepted_input", type => "date", min_resolution => "year", required => 1, show_in_html => 0,}
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_free_to_read_input", type => "compound", show_in_html => 0, fields => [
		{ sub_name => "free_to_read", type => "boolean" },
		{ sub_name => "start_date", type => "date", min_resolution => "day" },
		{ sub_name => "end_date", type => "date", min_resolution => "day" }
	] }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_license_ref_input", type => "compound", show_in_html => 0, fields => [
		{ sub_name => "license_ref", type => "url", input_cols => "45" },
		{ sub_name => "start_date", type => "date" }
	], required => 1 }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_apc_input", type => "set", show_in_html => 0, options => [ "paid", "partially waived", "fully waived", "not charged", "not required", "unknown" ] }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_project_input", type => "compound", show_in_html => 0, fields => [
		{ sub_name => "project", type => "text", input_cols => "25" },
		{ sub_name => "funder_name", type => "text", input_cols => "25", },
		{ sub_name => "funder_id", type => "url", input_cols => "25", }
	], required => 1, multiple => 1,
#	render_input => "rioxx2_project_input_renderer", 
	input_lookup_url =>"/cgi/users/lookup/rioxx2_project",
	input_lookup_params => "file=funderNames",
	}
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_publication_date_input", type => "text", show_in_html => 0, }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_type_input", type => "set", show_in_html => 0, options => [ "Book", "Book chapter", "Book edited", "Conference Paper/Proceeding/Abstract", "Journal Article/Review", "Manual/Guide", "Monograph", "Policy briefing report", "Technical Report", "Technical Standard", "Thesis", "Other", "Consultancy Report", "Working paper" ], required => 1, multiple => 1 }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_version_input", type => "set", show_in_html => 0, options => [qw( AO SMUR AM P VoR CVoR EVoR NA )], required => 1 }
);

# more complex mappings

$c->{rioxx2_source} = sub {
	my ( $eprint ) = @_;

	return unless $eprint->get_type eq "article" || $eprint->get_type eq "book_section" || $eprint->get_type eq "conference_item";

	for( qw( issn isbn publication book_title event_title ) )
	{
		next unless $eprint->is_set( $_ );
		return $eprint->value( $_ );
	}
};

$c->{rioxx2_free_to_read} = sub {
	my( $eprint, $document ) = @_;

	return undef unless $document;
	return { free_to_read => 1 } if $document->is_set( "security" ) && $document->value( "security" ) eq "public";
	return { free_to_read => 1, start_date => $document->value( "date_embargo" ) } if $document->is_set( "date_embargo" );
};

$c->{rioxx2_author} = sub {
	my( $eprint ) = @_;

	my @authors;
	for( @{ $eprint->value( "creators_name" ) } )
	{
		push @authors, EPrints::Utils::make_name_string( $_ );
	}
	push @authors, @{ $eprint->value( "corp_creators" ) };

	return \@authors;
};

$c->{rioxx2_contributor} = sub {
	my( $eprint ) = @_;

	my @contributors;
	for( @{ $eprint->value( "editors_name" ) }, @{ $eprint->value( "contributors_name" ) } )
	{
		push @contributors, EPrints::Utils::make_name_string( $_ );
	}

	return \@contributors;
};

$c->{rioxx2_project} = sub {
	my( $eprint ) = @_;

	return unless $eprint->is_set( "funders" ) && $eprint->is_set( "projects" );

	my @p = @{ $eprint->value( "projects" ) };
	my @f = @{ $eprint->value( "funders" ) };

	while( scalar @p < scalar @f )
	{
		push @p, $p[$#p];
	}

	my @projects;
	for( my $i = 0; $i < scalar @p; $i++ )
	{
		push @projects, {
			project => $p[$i],
			funder_name => ( $i > $#f ? $f[$#f] : $f[$i] ),
		};
	}
	return \@projects;
};

$c->{rioxx2_version_of_record} = sub {
	my( $eprint ) = @_;

	my $value;
	foreach my $field ( qw( doi id_number ) )
	{
		$value = $eprint->value( $field ) if $eprint->exists_and_set( $field );
		last if $value;
	}
	return unless $value;

	#If it is a DOI then it must be represented in HTTP form
	if ( $value =~ /10\..+\/.+/ )
	{
		$value = "http://dx.doi.org/".$value;
	}
	return $value;
};




# Validation Routines

$c->{rioxx2_validate_coverage} = sub {
	my( $repo, $value, $eprint ) = @_;

	my @problems = ();
	return @problems;

};

$c->{rioxx2_validate_description} = sub {
	my( $repo, $value, $eprint ) = @_;
	
	# reporting the field as abstract rather than the rioxx2 field 
	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "abstract" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:recommended_not_set", field=>$name );
		return @problems;
	} 
	# check for markup in the text

	use HTML::Parser;

	my $start_events = [];
	my $p = HTML::Parser->new(api_version => 3, );
	$p->handler( start => $start_events, '"S", attr, attrseq, text' );
	$p->parse( $value );
	if ( scalar @$start_events ) 
	{
		my $tags = "";
		foreach my $start ( @$start_events )
		{
			$tags .= $start->[3]." ";
			$tags .= " ";
		}
		push @problems, $repo->html_phrase( "rioxx2_validate:field_contains_markup", 
				field=>$name, 
				tags=>$repo->xml->create_text_node( $tags ) );
	}
	return @problems;
};

$c->{rioxx2_validate_mime_type} = sub {
	my( $repo, $value, $eprint ) = @_;
	
	my @documents = $eprint->get_all_documents;
	return unless scalar @documents;

	my $ds = $repo->dataset( "document" );
	my $source_field = $ds->field( "format" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:recommended_not_set", field=>$name );
	} 

	return @problems;
};

$c->{rioxx2_validate_identifier} = sub {
	my( $repo, $value, $eprint ) = @_;
	
	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:item_has_no_resource" );
	} 

	return @problems;
};

$c->{rioxx2_validate_language} = sub {
	my( $repo, $value, $eprint ) = @_;
	
	my $ds = $repo->dataset( "document" );
	my $source_field = $ds->field( "language" );
	my $name = $source_field->render_name;

	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:mandatory_not_set", field=>$name );
		return @problems;
	} 
# we could check the code against iso 639-1, -2 and -3 but we cannot use the official list as it would breach the terms of use:
#
#The ISO 639-3 code set may be downloaded and incorporated into software products, web-based systems, digital devices, etc., either commercial or non-commercial, provided that:

#attribution is given www.sil.org/iso639-3/ as the source of the codes;
#the identifiers of the code set are not modified or extended except as may be privately agreed using the Private Use Area (range qaa to qtz), and then such extensions shall not be distributed publicly;
#the product, system, or device does not provide a means to redistribute the code set.
#
# as this is a bazaar plugin the "product" would: "provide a means to redistribute the code set"

	# the value could be a scalar or an array!
	my $values = [];
	if ( ref $value eq "ARRAY" ) 
	{
		$values = $value;
	}
	else
	{
		push @$values, $value;
	}
 
	foreach my $v ( @$values )
	{
		if ( $v !~ /[a-z]{2,3}/ && $v !~ /[a-z]{2}-[a-zA-Z]{2}/ )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate:language_not_found", 
				field=>$name, 
				code=>$repo->xml->create_text_node( $v ) );
		}
	}

	return @problems;
};

$c->{rioxx2_validate_publisher} = sub {
	my( $repo, $value, $eprint ) = @_;
	
	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "publisher" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:recommended_not_set", field=>$name );
	} 

	return @problems;
};

$c->{rioxx2_validate_relation} = sub {
	my( $repo, $value, $eprint ) = @_;

	return unless $value;
	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "related_url" );
	my $name = $source_field->render_name;
	my @problems = ();
	foreach my $v ( @$value )
	{
		if ( $v !~ /http[.]?:\/\// )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate:not_an_http_uri", 
					field=>$name, 
					fvalue=>$repo->xml->create_text_node( $v ) );
		} 
	}

	return @problems;
};



$c->{rioxx2_validate_source} = sub {
	my( $repo, $value, $eprint ) = @_;

	my @problems = ();
	my $type = $eprint->get_value( "type" );
	return @problems unless $type =~ /article|book_section|conference_item/ ;
	
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:source_not_set" );
	} 
	return @problems;
};

$c->{rioxx2_validate_subject} = sub {
	my( $repo, $value, $eprint ) = @_;

	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "subjects" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:recommended_not_set", field=>$name );
	} 

	return @problems;
};


$c->{rioxx2_validate_title} = sub {
	my( $repo, $value, $eprint ) = @_;

	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "title" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:mandatory_not_set", field=>$name );
	} 

	return @problems;
};


$c->{rioxx2_validate_dateAccepted} = sub {
	my( $repo, $value, $eprint ) = @_;

	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "rioxx2_dateAccepted" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:mandatory_not_set", field=>$name );
	} 

	return @problems;
};


$c->{rioxx2_validate_free_to_read} = sub {
	my( $repo, $value, $eprint ) = @_;
	# This is an optional element the only possible thing to check is that all parts of any dates are specified 
	my @problems = ();
	return @problems unless $value;
	if ( $value->{start_date} && $value->{start_date} != /\d\d\d\d-\d\d-\d\d/ ) {
		push @problems, $repo->html_phrase( "rioxx2_validate:missing_free_start" );
	} 
	if ( $value->{end_date} && $value->{end_date} != /\d\d\d\d-\d\d-\d\d/ ) {
		push @problems, $repo->html_phrase( "rioxx2_validate:missing_free_end" );
	} 

	return @problems;
};


$c->{rioxx2_validate_license_ref} = sub {
	my( $repo, $value, $eprint ) = @_;
	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "rioxx2_license_ref" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:mandatory_not_set", field=>$name );
		return @problems;
	} 
	
	if ( $value->{license_ref} )
	{
		if ( $value->{license_ref} !~ /http.?\/\// )
		{
			push @problems, $repo->html_phrase( "rioxx2_validate:not_an_http_uri", 
				field=>$name,
				fvalue=>$repo->xml->create_text_node( $value->{license_ref} ) );
		}
	}
	else
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:missing_license_url" );
	}
	unless ( $value->{start_date} && $value->{start_date} =~ /\d\d\d\d-\d\d-\d\d/ )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:missing_license_start" );
		# could check that the date is a valid date
	}

	return @problems;
};


$c->{rioxx2_validate_apc} = sub {
	my( $repo, $value, $eprint ) = @_;
	# this field is optional and the values are taken from a controlled list

	my @problems = ();
	return @problems;
};


$c->{rioxx2_validate_author} = sub {
	my( $repo, $value, $eprint ) = @_;

	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "creators" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value || 0 == scalar @$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:mandatory_not_set", field=>$name );
	} 
	
	# at the moment the id field is not specified but when it is we should validate the contents
	return @problems;
};


$c->{rioxx2_validate_contributor} = sub {
	my( $repo, $value, $eprint ) = @_;

	# this field is optional and the id field is not specified but when it is we should validate the contents
	my @problems = ();
	return @problems;
};


$c->{rioxx2_validate_project} = sub {
	my( $repo, $value, $eprint ) = @_;

	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "rioxx2_project" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value || 0 == scalar @$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:mandatory_not_set", field=>$name );
	} 
	
	my $funder_lookup = {};
	my $filepath = $repo->config( "fundref_csv_file" );
	if ( open( DATA, '<', $filepath ) )
	{
		while( <DATA> )
		{
        		my( $uri, $name ) = split( /,/, $_, 2 );
		        $name =~ /^"(.+)"/;
			next unless $1;
			$name = lc $1;
			$funder_lookup->{$name} = $uri;
		}
		close DATA;
	}

	foreach my $project ( @$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:project_not_set" ) unless $project->{project};
		push @problems, $repo->html_phrase( "rioxx2_validate:funder_not_set" ) unless ( $project->{funder_name} || $project->{funder_id} );
		my $name_found = 0;
		my $id_found = 0;
		my $funder;
		if ( $project->{funder_name} )
		{
			$funder = lc($project->{funder_name});
			my @lookup_names = keys %$funder_lookup;
			if ( scalar @lookup_names )
			{
				$name_found = grep { index( $_, $funder ) != -1 } @lookup_names;
				push @problems, $repo->html_phrase( "rioxx2_validate:funder_not_in_list" ) unless $name_found;
			}
			else
			{
				push @problems, $repo->html_phrase( "rioxx2_validate:no_funder_controlled_list" );
			}
		}
		if ( $project->{funder_id} )
		{
			my @lookup_ids = values %$funder_lookup;
			if ( scalar @lookup_ids )
			{
				$id_found = grep { index( $_, $project->{funder_id} ) != -1 } @lookup_ids;
				push @problems, $repo->html_phrase( "rioxx2_validate:funder_id_not_in_list" ) unless $id_found;
			}
		}
		if ( $name_found && $id_found )
		{
			if ( $funder_lookup->{$funder} ne $project->{funder_id} )
			{
				push @problems, $repo->html_phrase( "rioxx2_validate:funder_no_match_for_name_id" );
			}
		}

	}
	return @problems;
};


$c->{rioxx2_validate_publication_date} = sub {
	my( $repo, $value, $eprint ) = @_;

	# this is an optional free text field 
	my @problems = ();
	return @problems;
};


$c->{rioxx2_validate_type} = sub {
	my( $repo, $value, $eprint ) = @_;
	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "rioxx2_type" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value )
	{
		# this should not happen but just in case...
		push @problems, $repo->html_phrase( "rioxx2_validate:mandatory_not_set", field=>$name );
	} 
	#not much point in checking the actual value as it is selected from a controlled list
	return @problems;
};


$c->{rioxx2_validate_version} = sub {
	my( $repo, $value, $eprint ) = @_;
	my $ds = $repo->dataset( "eprint" );
	my $source_field = $ds->field( "rioxx2_version" );
	my $name = $source_field->render_name;
	my @problems = ();
	if ( !$value )
	{
		# this should not happen but just in case...
		push @problems, $repo->html_phrase( "rioxx2_validate:mandatory_not_set", field=>$name );
	} 
	#not much point in checking the actual value as it is selected from a controlled list
	return @problems;
};


$c->{rioxx2_validate_version_of} = sub {
	my( $repo, $value, $eprint ) = @_;
	my $ds = $repo->dataset( "eprint" );
	my $source_field;
	foreach my $field ( qw( rioxx2_version_of_record id_number doi ) )
	{
		$source_field = $ds->field( $field ) if $ds->has_field( $field );
	}
	my $name = $source_field->render_name;
	
	my @problems = ();
	if ( !$value )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:recommended_not_set", field=>$name );
		return @problems;
	} 
	if ( $value !~ /http.?\/\// )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate:not_an_http_uri", 
				field=>$name,
				fvalue=>$repo->xml->create_text_node( $value ) );
	}

	return @problems;
};


$c->{rioxx2_project_input_renderer} = sub {
	my( $field, $repo, $value, $dataset, $staff, $hidden_fields, $obj, $basename ) = @_;

        my $frag = $repo->make_doc_fragment;
	my $elements = $field->get_input_elements( $repo, $value, $staff, $obj, $basename );

	my $table = $repo->make_element( "table", border=>0, cellpadding=>0, cellspacing=>0, class=>"ep_form_input_grid" );
	$frag->appendChild ($table);

	my $col_titles = $field->get_input_col_titles( $repo, $staff );
	if( defined $col_titles )
	{
		my $tr = $repo->make_element( "tr" );
		my $th;
		my $x = 0;
		if( $field->get_property( "multiple" ) && $field->{input_ordered})
		{
			$th = $repo->make_element( "th", class=>"empty_heading", id=>$basename."_th_".$x++ );
			$tr->appendChild( $th );
		}

		if( !defined $col_titles )
		{
			$th = $repo->make_element( "th", class=>"empty_heading", id=>$basename."_th_".$x++ );
			$tr->appendChild( $th );
		}	
		else
		{
			foreach my $col_title ( @{$col_titles} )
			{
				$th = $repo->make_element( "th", id=>$basename."_th_".$x++ );
				$th->appendChild( $col_title );
				$tr->appendChild( $th );
			}
		}
		$table->appendChild( $tr );
	}

	my $y = 0;
	foreach my $row ( @{$elements} )
	{
		my $x = 0;
		my $tr = $repo->make_element( "tr" );
		foreach my $item ( @{$row} )
		{
			my %opts = ( valign=>"top", id=>$basename."_cell_".$x++."_".$y );
			foreach my $prop ( keys %{$item} )
			{
				next if( $prop eq "el" );
				$opts{$prop} = $item->{$prop};
			}	
			my $td = $repo->make_element( "td", %opts );
			if( defined $item->{el} )
			{
				$td->appendChild( $item->{el} );
			}
			$tr->appendChild( $td );
		}
		$table->appendChild( $tr );
		$y++;
	}

	my $extra_params = URI->new( 'http:' );
	$extra_params->query( $field->{input_lookup_params} );
	my @params = (
		$extra_params->query_form,
		field => $field->name
	);
	if( defined $obj )
	{
		push @params, dataobj => $obj->id;
	}
	if( defined $field->{dataset} )
	{
		push @params, dataset => $field->{dataset}->id;
	}
	$extra_params->query_form( @params );
	$extra_params = "&" . $extra_params->query;

	my $componentid = substr($basename, 0, length($basename)-length($field->{name})-1);
	my $url = EPrints::Utils::js_string( $field->{input_lookup_url} );
	my $params = EPrints::Utils::js_string( $extra_params );
	$frag->appendChild( $repo->make_javascript( <<EOJ ) );
new Metafield ('$componentid', '$field->{name}', {
	input_lookup_url: $url,
	input_lookup_params: $params
});
EOJ


	return $frag;
};



