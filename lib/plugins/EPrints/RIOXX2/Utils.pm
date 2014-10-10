package EPrints::RIOXX2::Utils;

use HTML::Parser;
use strict;

sub is_valid_funder
{
	my( $value ) = @_;

	return 1;
}

sub is_http_uri
{
	my( $value ) = @_;

	return $value =~ /^http:/i;
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

__DATA__

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
