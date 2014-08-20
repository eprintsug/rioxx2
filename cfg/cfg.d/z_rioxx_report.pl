
my @rioxx2_fields = (
	{
		target => "EPrint ID",
		source => "eprint.eprintid",
		validate => "required",
	},
	{
		target => "dc:coverage",
		source => "eprint.rioxx2_coverage",
		validate => "recommended",
	},
	{
		target => "dc:description",
		source => "eprint.abstract",
		validate => "required",
	},
	{
		target => "dc:format",
		source => sub {
			my( $plugin, $objects ) = @_;

			my $eprint = $objects->{eprint};
			my @docs = $eprint->get_all_documents;
			if ( @docs )
			{
				my $doc = $docs[0];
				return $doc->value( "mime_type" );
			}
			return undef;
		},
		validate => "required",
	},
	{
		target => "dc:identifier",
		source => sub {
			my( $plugin, $objects ) = @_;

			my $eprint = $objects->{eprint};
			my @docs = $eprint->get_all_documents;
			if ( @docs )
			{
				my $doc = $docs[0];
				return $doc->get_url;
			}
			return undef;
		},
	
		validate => "required",
	},
	{
		target => "dc:language",
		source => "eprint.rioxx2_language",
		validate => "required",
	},
	{
		target => "dc:publisher",
		source => "eprint.publisher",
		validate => "required",
	},
	{
		target => "dc:relation",
		source => "eprint.related_url->{url}",
		validate => "required",
	},
	{
		target => "dc:source",
		source => "eprint.issn",
		validate => "required",
	},
	{
		target => "dc:subject",
		source => "eprint.subjects",
		validate => "required",
	},
	{
		target => "dc:title",
		source => "eprint.title",
		validate => "required",
	},
	{
		target => "dcterms:dateAccepted",
		source => "eprint.rioxx2_date_accepted",
		validate => "required",
	},
	{
		target => "free_to_read",
		source => "eprint.rioxx2_freetoread",
		validate => "required",
	},
	{
		target => "license_ref",
		source => "eprint.rioxx2_license",
		validate => "required",
	},
	{
		target => "rioxxterms:apc",
		source => "eprint.rioxx2_apc",
		validate => "required",
	},
	{
		target => "rioxxterms:author",
		source => "eprint.creators",
		validate => "required",
	},
	{
		target => "rioxxterms:contributor",
		source => "eprint.editors",
		validate => "required",
	},
	{
		target => "rioxxterms:project",
		source => "eprint.rioxx2_project",
		validate => "required",
	},
	{
		target => "rioxxterms:publication_date",
		source => "eprint.rioxx2_publication_date",
		validate => "required",
	},
	{
		target => "rioxxterms:type",
		source => "eprint.rioxx2_type",
		validate => "required",
	},
	{
		target => "rioxxterms:version",
		source => "eprint.rioxx2_version",
		validate => "required",
	},
	{
		target => "rioxxterms:version_of_record",
		source => sub {
			my( $plugin, $objects ) = @_;
			my $eprint = $objects->{eprint};
			if ( $eprint->exists_and_set( 'doi' ) )
			{
				return $eprint->value( 'doi' );
			}
			elsif ( $eprint->is_set ( 'id_number' ) )
			{
				return $eprint->value( 'id_number' );
			}
			return undef;
		},
		validate => "required",
	},
);

$c->{reports}->{"rioxx2-articles"}->{fields} = [ map { $_->{target} } @rioxx2_fields ];
$c->{reports}->{"rioxx2-articles"}->{mappings} = { map { $_->{target} => $_->{source} } @rioxx2_fields };
$c->{reports}->{"rioxx2-articles"}->{validate} = { map { $_->{target} => $_->{validate} } @rioxx2_fields };


my @example_fields = (
	{
		target => "EPrint ID",
		source => "eprint.eprintid",
		validate => "required",
	},
	{
		target => "Title",
		# just to demonstrate getting data via a sub {}
		source => sub {
			my( $plugin, $objects ) = @_;

			my $eprint = $objects->{eprint};
			return $eprint->value( 'title' );
		},
		validate => sub {
			my( $plugin, $objects, $problems ) = @_;

			my $eprint = $objects->{eprint};

			if( $eprint->value( 'title' ) =~ /the/i )
			{
				push @$problems, "Problems detected!!";
			}
		}
	},
);

$c->{reports}->{"example-articles"}->{fields} = [ map { $_->{target} } @example_fields ];
$c->{reports}->{"example-articles"}->{mappings} = { map { $_->{target} => $_->{source} } @example_fields };
$c->{reports}->{"example-articles"}->{validate} = { map { $_->{target} => $_->{validate} } @example_fields };

$c->{reports}->{"example-conf-items"}->{fields} = [ map { $_->{target} } @example_fields ];
$c->{reports}->{"example-conf-items"}->{mappings} = { map { $_->{target} => $_->{source} } @example_fields };
$c->{reports}->{"example-conf-items"}->{validate} = { map { $_->{target} => $_->{validate} } @example_fields };
