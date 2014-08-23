# New EPrint Fields for RIOXX2

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_coverage", type => "text", multiple => 1 }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_language", type => "namedset", input_rows => 1, set_name => "languages", multiple => 1, required => 1 }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_dateAccepted", type => "date", min_resolution => "year", required => 1 }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_free_to_read", type => "compound", fields => [
		{ sub_name => "free_to_read", type => "boolean" },
		{ sub_name => "start_date", type => "date", min_resolution => "day" },
		{ sub_name => "end_date", type => "date", min_resolution => "day" }
	] }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_license_ref", type => "compound", fields => [
		{ sub_name => "license_ref", type => "url" },
		{ sub_name => "start_date", type => "date" }
	], required => 1 }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_apc", type => "set", options => [qw( paid partially_waived fully_waived not_charged not_required unknown )] }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_project", type => "compound",	fields => [
		{ sub_name => "project", type => "text" },
		{ sub_name => "funder_name", type => "text" },
		{ sub_name => "funder_id", type => "url" }
	], required => 1, multiple => 1 }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_publication_date", type => "text" }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_type", type => "set", options => [qw( book book_chapter book_edited conference_item journal_article manual monograph policy_report tech_report tech_standard thesis other consultancy_report working_paper )], required => 1, multiple => 1 }
);

$c->add_dataset_field(
	"eprint",
	{ name => "rioxx2_version", type => "set", options => [qw( AO SMUR AM P VoR CVoR EVoR NA )], required => 1 }
);
