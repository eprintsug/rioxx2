package EPrints::Plugin::Export::Report;

use EPrints::Plugin::Export;

@ISA = ( "EPrints::Plugin::Export" );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{name} = "Report Export (Abstract)";
	$self->{accept} = [ 'report/*' ];
	$self->{advertise} = 0;
	$self->{enable} = 1;
	$self->{visible} = 'staff';

	return $self;
}

sub initialise_fh
{
	my( $plugin, $fh ) = @_;

	binmode($fh, ":utf8" );

	# seems a bit hacky but that's the right place to send some extra HTTP headers - this one will tell the browser which files to save this report as.

	my $filename = ($plugin->{report}||'report')."_".EPrints::Time::iso_date().($plugin->{suffix}||".txt");

	EPrints::Apache::AnApache::header_out(
		$plugin->repository->get_request,
			"Content-Disposition" => "attachment; filename=$filename"
	);
}

# Which report are we currently exporting?
sub get_report { shift->{report} }

# TODO Note copy of Screen::Report::report_fields_order
sub report_fields_order
{
	my( $plugin ) = @_;

	return $plugin->{report_fields_order} if( defined $plugin->{report_fields_order} );

	my $report = $plugin->get_report();
	return [] unless( defined $report );

	$plugin->{report_fields_order} = $plugin->repository->config( 'reports', $report, 'fields' );

	return $plugin->{report_fields_order};
}

# TODO Note copy of Screen::Report::report_fields
sub report_fields
{
	my( $plugin ) = @_;

	return $plugin->{report_fields} if( defined $plugin->{report_fields} );

	my $report = $plugin->get_report();
	return [] unless( defined $report );

	$plugin->{report_fields} = $plugin->repository->config( 'reports', $report, 'mappings' );

	return $plugin->{report_fields};
}

# TODO Note copy of Screen::Report::get_related_objects
sub get_related_objects
{
	my( $plugin, $dataobj ) = @_;

	my $cmd = [ 'reports', $plugin->get_report, 'get_related_objects' ];
        if( $plugin->repository->can_call( @$cmd ) )
        {
		return $plugin->repository->call( $cmd, $plugin->repository, $dataobj ) || {};
        }

	# just pass the dataobj itself
	return {
		$dataobj->dataset->confid => $dataobj,
	};
}

1;
