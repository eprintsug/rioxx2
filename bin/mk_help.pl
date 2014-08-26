#!/usr/bin/perl -w

use HTML::TableExtract;
use strict;

print <<HEAD;
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<!DOCTYPE phrases SYSTEM "entities.dtd">
<epp:phrases xmlns="http://www.w3.org/1999/xhtml" xmlns:epp="http://eprints.org/ep3/phrase" xmlns:epc="http://eprints.org/ep3/control">
HEAD

my $te = HTML::TableExtract->new( headers => [qw( Element Cardinality Description )], keep_html => 1, strip_html_on_match => 1 );
$te->parse_file( $ARGV[0] );

foreach my $row ($te->rows) {

	for( @$row )
	{
		s/^\s*//s;
		s/\s*$//s;;
	}

	my( $name, undef, $desc ) = @$row;

	$name =~ /^([^:]+:)?(.*)$/;

	print <<PHRASE;
<epp:phrase id="eprint_fieldhelp_rioxx2_$2">$desc</epp:phrase>
PHRASE
}

print <<TAIL
</epp:phrases>
TAIL
