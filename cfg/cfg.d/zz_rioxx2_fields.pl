# New EPrint Fields for RIOXX2

push @{$c->{fields}->{eprint}},

{
	name => 'rioxx2_coverage',
	type => 'text',
	multiple => 1,
},
{
	name => 'rioxx2_language',
	type => 'namedset',
	input_rows => 1,
	set_name => "languages",
	multiple => 1,
	required => 1,
},
{
	name => 'rioxx2_date_accepted',
	type => 'date',
	min_resolution => 'month',
	required => 1,
},
{
	name => 'rioxx2_freetoread',
	type => 'compound',	
	fields => [
		{
			sub_name => 'start',
			type => 'date',
		},
		{
			sub_name => 'end',
			type => 'date',
		}
	],

},
{
	name => 'rioxx2_license',
	type => 'compound',	
	fields => [
		{
			sub_name => 'url',
			type => 'url',
		},
		{
			sub_name => 'start',
			type => 'date',
		}
	],
	required => 1,
},
{
	name => 'rioxx2_apc',
	type => 'set',
	options => [qw(
		paid
		partially_waived
		fully_waived
		not_charged
		not_required
		unknown
	)],
},
{
	name => 'rioxx2_project',
	type => 'compound',	
	fields => [
		{
			sub_name => 'id',
			type => 'text',
		},
		{
			sub_name => 'funder_name',
			type => 'text',
		},
		{
			sub_name => 'funder_id',
			type => 'url',
		}
	],
	required => 1,
	multiple => 1,
},
{
	name => 'rioxx2_publication_date',
	type => 'text',
},
{
	name => 'rioxx2_type',
	type => 'set',
	options => [qw(
		book
		book_chapter
		book_edited
		conference_item
		journal_article
		manual
		monograph
		policy_report
		tech_report
		tech_standard
		thesis
		other
		consultancy_report
		working_paper
	)],
	required => 1,
	multiple => 0,			# N.B. Profile says this is a "one or more"
},
{
	name => 'rioxx2_version',
	type => 'set',
	options => [qw(
		ao
		smur
		am
		p
		vor
		cvor
		evor
		na
	)],
	required => 1,
},
;




