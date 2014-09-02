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
	{ name => "rioxx2_source", type => "rioxx2", rioxx2_value => "rioxx2_source", rioxx2_required => "mandatory", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_subject", type => "rioxx2", rioxx2_value => sub { $_[0]->value( "subjects" ) }, rioxx2_required => "recommended", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_title", type => "rioxx2", rioxx2_value => sub { $_[0]->value( "title" ) }, rioxx2_required => "mandatory", rioxx2_ns => "dc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_dateAccepted", type => "rioxx2", rioxx2_required => "mandatory", rioxx2_ns => "dcterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_free_to_read", type => "rioxx2", rioxx2_value => "rioxx2_free_to_read", rioxx2_required => "optional", rioxx2_ns => "tbc" }
);

$c->add_dataset_field(
	"eprint",
	# TODO rioxx2_value: derive from document.license + document.date_embargo
	# TODO rioxx2_validate: license_ref must be HTTP URL, must include start_date
	{ name => "rioxx2_license_ref", type => "rioxx2", rioxx2_required => "mandatory", rioxx2_ns => "tbc" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_apc", type => "rioxx2", rioxx2_required => "optional", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_author", type => "rioxx2", rioxx2_value => "rioxx2_author", rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_contributor", type => "rioxx2", rioxx2_value => "rioxx2_contributor", rioxx2_required => "optional", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_project", type => "rioxx2", rioxx2_value => "rioxx2_project", rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_publication_date", type => "rioxx2", rioxx2_value => sub { ( !$_[0]->is_set( "date_type" ) || $_[0]->value( "date_type" ) eq "published" ) && $_[0]->value( "date" ) }, rioxx2_required => "optional", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_type", type => "rioxx2", rioxx2_value => sub { $_[0]->repository->config( "rioxx2", "type_map", $_[0]->get_type ) || "other" }, rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_version", type => "rioxx2", rioxx2_value => sub { $_[1] && $_[1]->repository->config( "rioxx2", "content_map", $_[1]->value( "content" ) ) || "NA" }, rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
);

$c->add_dataset_field(
	"eprint",
	# TODO check id_number contains a DOI
	# TODO rioxx2_validate: must be a HTTP URL
	# this is more of a conditional mandatory rather than a mandatory i.e. if there is a DOI it is manadatory
	# we could therefore say that if it is published and an article then it is manadtory.
	{ name => "rioxx2_version_of_record", type => "rioxx2", rioxx2_value => sub { ( $_[0]->exists_and_set( "doi" ) && $_[0]->value( "doi" ) ) || $_[0]->value( "id_number" ) }, rioxx2_required => "mandatory", rioxx2_ns => "rioxxterms" }
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
		{ sub_name => "license_ref", type => "url" },
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
		{ sub_name => "project", type => "text" },
		{ sub_name => "funder_name", type => "text" },
		{ sub_name => "funder_id", type => "url" }
	], required => 1, multiple => 1 }
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

	return unless $document;
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

	my @contributors;;
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

# Validation Routines

$c->{rioxx2_validate_coverage} = sub {
	my( $eprint ) = @_;

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






