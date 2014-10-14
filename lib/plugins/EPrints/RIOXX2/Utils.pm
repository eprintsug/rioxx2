package EPrints::RIOXX2::Utils;

use HTML::Parser;
use strict;

sub is_valid_funder_name
{
	my( $value, $funder_lookup) = @_;

	my $funder = lc($value);
	my @lookup_names = keys %$funder_lookup;
	if ( scalar @lookup_names )
	{
		my $name_found = grep { index( $_, $funder ) != -1 } @lookup_names;
		return $name_found;
	}
	return 0;
}
sub is_valid_funder_id
{
	my( $value, $name, $funder_lookup ) = @_;

	my $funder = lc($name);
	return 1 unless $funder_lookup->{$funder};
	return $value eq $funder_lookup->{$funder};
}

sub get_funder_lookup
{
	my( $repo ) = @_;
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
	return $funder_lookup;
}

sub is_http_uri
{
	my( $value ) = @_;

	my @v = ref( $value ) eq "ARRAY" ? @$value : ( $value );
	for( @v )
	{
		return 0 unless /^http:/i;
	}
	return 1;
}

sub is_iso_8601_date
{
	my( $value ) = @_;

	return $value =~ /^\d{4}-\d{2}-\d{2}$/;
}

sub contains_markup
{
	my( $value ) = @_;

	my $start_events = [];
	my $p = HTML::Parser->new(api_version => 3, );
	$p->handler( start => $start_events, '"S", attr, attrseq, text' );
	$p->parse( $value );

	return scalar @$start_events;
}

1;

