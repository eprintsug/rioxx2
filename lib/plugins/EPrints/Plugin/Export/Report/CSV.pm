package EPrints::Plugin::Export::Report::CSV;

use EPrints::Plugin::Export::Report;
@ISA = ( "EPrints::Plugin::Export::Report" );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new( %params );

	$self->{name} = "Generic CSV";
	$self->{suffix} = ".csv";
	$self->{mimetype} = "text/plain; charset=utf-8";

	return $self;
}

# Main method - called by the appropriate Screen::Report plugin
sub output_list
{
        my( $plugin, %opts ) = @_;
       
	# the appropriate Report::{report_id} plugin will build up the list: 

	# CSV header / field list
	print join( ",", map { $plugin->escape_value( $_ ) } @{ $plugin->report_fields_order || [] } ) . "\n";

	$opts{list}->map( sub {
		my( undef, undef, $dataobj ) = @_;
		my $output = $plugin->output_dataobj( $dataobj, $plugin->get_related_objects( $dataobj ) );
		return unless( defined $output );
		print "$output\n";
	} );
}

# Exports a single object / row
# TODO Note quite a lot of replication between this and Screen::Report::validate_dataobj
sub output_dataobj
{
	my( $plugin, $dataobj, $objects ) = @_;

	my $repo = $plugin->repository;

	my $report_fields = $plugin->report_fields();

	# related objects and their datasets
	my $valid_ds = {};
	foreach my $dsid ( keys %$objects )
	{
		$valid_ds->{$dsid} = $repo->dataset( $dsid );
	}

	# don't print out empty row so check that something's been done:
	my $done_any = 0;

	my @row;
	foreach my $field ( @{ $plugin->report_fields_order() } )
	{
		my $ep_field = $report_fields->{$field};

		if( ref( $ep_field ) eq 'CODE' )
		{
			# a sub{} we need to run
			eval {
				my $value = &$ep_field( $plugin, $objects );
				if( EPrints::Utils::is_set( $value ) )
				{
					push @row, $plugin->escape_value( $value );
					$done_any++ 
				}
				else
				{
					push @row, "";
				}
			};
			if( $@ )
			{
				$repo->log( "Report::CSV Runtime error: $@" );
			}

			next;
		}
		elsif( $ep_field !~ /^([a-z_]+)\.([a-z_]+)$/ )
		{
			# wrong format :-/
			push @row, "";
			next;
		}

		# a straight mapping with an EPrints field
		my( $ds_id, $ep_fieldname ) = ( $1, $2 );
		my $ds = $valid_ds->{$ds_id};

		unless( defined $ds && $ds->has_field( $ep_fieldname ) )
		{
			# dataset or field doesn't exist
			push @row, "";
			next;
		}

		my $value = $objects->{$ds_id}->value( $ep_fieldname );
		$done_any++ if( EPrints::Utils::is_set( $value ) );
		push @row, $plugin->escape_value( $value );
	}

	return undef unless( $done_any );

	return join( ",", @row );
}

sub escape_value
{
	my( $plugin, $value ) = @_;

	return '""' unless( defined EPrints::Utils::is_set( $value ) );

	# strips any kind of double-quotes:
	$value =~ s/\x93|\x94|"/'/g;
	# and control-characters
	$value =~ s/\n|\r|\t//g;

	# if value is a pure number, then add ="$value" so that Excel stops the auto-formatting (it'd turn 123456 into 1.23e+6)
	if( $value =~ /^[0-9\-]+$/ )
	{
		return "=\"$value\"";
	}

	# only escapes row with spaces and commas
	if( $value =~ /,| / )
	{
		return "\"$value\"";
	}

	return $value;
}


1;
