
my @rioxx2_fields = (
	{
		target => "dc:coverage",
		source => "eprint.rioxx2_coverage",
	},
	{
		target => "dc:description",
		source => "eprint.rioxx2_description",
	},
	{
		target => "dc:format",
		source => "eprint.rioxx2_format",
	},
	{
		target => "dc:identifier",
		source => "eprint.rioxx2_identifier",
		validate => "required",
	},
	{
		target => "dc:language",
		source => "eprint.rioxx2_language",
		validate => "required",
	},
	{
		target => "dc:publisher",
		source => "eprint.rioxx2_publisher",
	},
	{
		target => "dc:relation",
		source => "eprint.rioxx2_relation",
	},
	{
		target => "dc:source",
		source => "eprint.rioxx2_source",
		validate => "required",
	},
	{
		target => "dc:subject",
		source => "eprint.rioxx2_subject",
	},
	{
		target => "dc:title",
		source => "eprint.rioxx2_title",
		validate => "required",
	},
	{
		target => "dcterms:dateAccepted",
		source => "eprint.rioxx2_dateAccepted",
		validate => "required",
	},
	{
		target => "free_to_read",
		source => "eprint.rioxx2_free_to_read",
	},
	{
		target => "license_ref",
		source => "eprint.rioxx2_license_ref", 
		validate => "required",
	},
	{
		target => "rioxxterms:apc",
		source => "eprint.rioxx2_apc",
	},
	{
		target => "rioxxterms:author",
		source => "eprint.rioxx2_author",
		validate => "required",
	},
	{
		target => "rioxxterms:contributor",
		source => "eprint.rioxx2_contributor",
	},
	{
		target => "rioxxterms:project",
		source => "eprint.rioxx2_project",
		validate => "required",
	},
	{
		target => "rioxxterms:publication_date",
		source => "eprint.rioxx2_publication_date",
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
		source => "eprint.rioxx2_version_of_record",
	},
);


$c->{reports}->{"rioxx2-articles"}->{fields} = [ map { $_->{target} } @rioxx2_fields ];
$c->{reports}->{"rioxx2-articles"}->{mappings} = { map { $_->{target} => $_->{source} } @rioxx2_fields };
$c->{reports}->{"rioxx2-articles"}->{validate} = { map { $_->{target} => $_->{validate} } @rioxx2_fields };

# Enable optional RIOXX2 plugins for reporting framework (https://github.com/eprints/reports)
$c->{plugins}{"Screen::Report::RIOXX2"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::Articles"}{params}{disable} = 0;
$c->{plugins}{"Export::Report::CSV::RIOXX2"}{params}{disable} = 0;
