package EPrints::Plugin::Screen::Report;

# Abstract class that handles the Report tools

use JSON qw();
use EPrints::Plugin::Screen;
@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	push @{$self->{actions}}, qw( export );

        $self->{appears} = [
                {
                        place => "key_tools",
                        position => 1000,
                },
        ];

	return $self;
}

sub get_report { shift->{report} }

sub can_be_viewed
{
        my( $self ) = @_;

	return 0 if( !defined $self->{repository}->current_user );

	return $self->allow( 'report' );
}

sub allow_export { shift->can_be_viewed }
sub action_export {}

sub wishes_to_export {
	$_[0]->repository->param( 'export' ) ||
	$_[0]->repository->param( 'ajax' );
}

sub export_mimetype
{
	my( $self ) = @_;

	my $plugin = $self->{processor}->{plugin};
	if( !defined $plugin )
	{
		if( $self->repository->param( "ajax" ) )
		{
			return "application/json; charset=utf-8";
		}
	
		return "text/html; charset=utf-8";
	}

	return $plugin->param( "mimetype" );
}

sub export
{
	my( $self ) = @_;

	my $part = $self->repository->param( "ajax" );
	my $f = "ajax_$part";

	if( $self->can( $f ) )
	{
		binmode(STDOUT, ":utf8");
		return $self->$f;
	}

	my $plugin = $self->{processor}->{plugin};
	return $self->SUPER::export if !defined $plugin;

	$plugin->initialise_fh( \*STDOUT );
	$plugin->output_list(
		list => $self->items,
		fh => \*STDOUT,
	);
}

sub properties_from
{
	my( $self ) = @_;

	$self->SUPER::properties_from;

	if( defined ( my $dsid = $self->param( "datasetid" ) ) )
	{
		$self->{processor}->{dataset} = $self->repository->dataset( $dsid );
	}


	# sf2 - TODO - bark if dataset is not set? perhaps there are other ways to get the objects from...


	my $report = $self->get_report();

	my $format = $self->repository->param( "export" );
	if( $format && $report )
	{
		my $plugin = $self->repository->plugin( "Export::$format", report => $report );
		if( defined $plugin && $plugin->can_accept( "report/$report" ) )
		{
			$self->{processor}->{plugin} = $plugin;
		}
	}
}

# \@({meta_fields=>[ "field1", "field2" "document.field3" ], merge=>"ANY", match=>"EX", value=>"bees"}, {meta_fields=>[ "field4" ], value=>"honey"});
# e.g.
# return [ { meta_fields => [ 'type' ], value => 'article' } ]
sub filters
{
	return [];
}

# how to select items i.e. the slice of data we want to validate/export?
# 
sub items
{
	my( $self ) = @_;

print STDERR "Report::items  dataset[".$self->{processor}->{dataset}."] order[".$self->param( 'custom_order' )."]\n"; 
	if( defined $self->{processor}->{dataset} )
	{
		my %search_opts = ( filters => $self->filters, satisfy_all => 1 );
		if( defined $self->param( 'custom_order' ) )
		{
			$search_opts{custom_order} = $self->param( 'custom_order' );
		}


		return $self->{processor}->{dataset}->search( %search_opts );
	}

	# we can't return an EPrints::List if {dataset} is not defined
	return undef;
}

# from Reports/ROS/Journals.pm
# TODO Note quite a lot of replication between this and Export::Report::CSV::output_dataobj
sub validate_dataobj
{
	my( $plugin, $dataobj ) = @_;

print STDERR "Report::validate \n"; 
	my $repo = $plugin->repository;

	my $report_fields = $plugin->report_fields( $dataobj );
	my $val_fields = $plugin->validate_fields( $dataobj );

	# related objects and their datasets
	my $objects = $plugin->get_related_objects( $dataobj );
	my $valid_ds = {};
	foreach my $dsid ( keys %$objects )
	{
		$valid_ds->{$dsid} = $repo->dataset( $dsid );
	}

	my @problems;

	foreach my $field ( @{ $plugin->report_fields_order( $dataobj ) || [] } )
	{
		# validation action
		my $v_field = $val_fields->{$field};
		next unless defined $v_field; # no validation required

		# simple case - code handles validation
		if( ref( $v_field ) eq 'CODE' )
		{
			# a sub{} we need to run
			eval {
				&$v_field( $plugin, $objects, \@problems );
			};
			if( $@ )
			{
				$repo->log( "Validation Runtime error: $@" );
			}
			next;
		}
		elsif( lc $v_field ne "required" )
		{
			$repo->log( "Validation Runtime error: $v_field must be code ref or 'required'" );
			next;
		}

		# check required values

		my $value; # the value to validate
		my $ep_field = $report_fields->{$field};
		if( ref( $ep_field ) eq 'CODE' )
		{
			# a sub{} we need to run
			eval {
				$value = &$ep_field( $plugin, $objects );
			};
			if( $@ )
			{
				$repo->log( "Validation Runtime error: $@" );
			}
		}
		elsif( $ep_field =~ /^([a-z_]+)\.([a-z_]+)$/ )
		{
			# a straight mapping with an EPrints field
			my( $ds_id, $ep_fieldname ) = ( $1, $2 );
			my $ds = $valid_ds->{$ds_id};

			if( defined $ds && $ds->has_field( $ep_fieldname ) )
			{
				$value = $objects->{$ds_id}->value( $ep_fieldname );
			}
			else
			{
				# dataset or field doesn't exist
				$repo->log( "Validation Runtime error: dataset $ds_id or field $ep_fieldname doesn't exist" );
			}
		}

		# is field set?
		if( !EPrints::Utils::is_set( $value ) )
		{
			push @problems, "Missing required field $field";
		}
	}

	return @problems;
}

# TODO Note copy of Export::Report::get_related_objects
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

# TODO Note copy of Export::Report::report_fields_order
sub report_fields_order
{
	my( $plugin ) = @_;

	return $plugin->{report_fields_order} if( defined $plugin->{report_fields_order} );

	my $report = $plugin->get_report();
	return [] unless( defined $report );

	$plugin->{report_fields_order} = $plugin->repository->config( 'reports', $report, 'fields' );

	return $plugin->{report_fields_order};
}

# TODO Note copy of Export::Report::report_fields
sub report_fields
{
	my( $plugin ) = @_;

	return $plugin->{report_fields} if( defined $plugin->{report_fields} );

	my $report = $plugin->get_report();
	return [] unless( defined $report );

	$plugin->{report_fields} = $plugin->repository->config( 'reports', $report, 'mappings' );

	return $plugin->{report_fields};
}

sub validate_fields
{
	my( $plugin ) = @_;
print STDERR "Report::validate_fields \n"; 

	return $plugin->{validate_fields} if( defined $plugin->{validate_fields} );

	my $report = $plugin->get_report();
	return [] unless( defined $report );

	$plugin->{validate_fields} = $plugin->repository->config( 'reports', $report, 'validate' );

	return $plugin->{validate_fields};
}

## rendering

# The "splash page"
sub render_splash_page
{
	my( $self ) = @_;

print STDERR "Report::render_splash_page \n"; 
	my @plugins = $self->report_plugins;

	if( !scalar( @plugins ) )
	{
		return $self->html_phrase( "no_reports" );
	}

	# top category: by classname > Report::ROS::SomeReport1, Report::ROS::SomeReport2

	my $ul = $self->repository->make_element( 'ul', class => 'ep_report_category' );

	# cat ~ category - !meeow
	my $cat = "";
	my $cat_li = undef; 
	my $cat_ul = undef;

	foreach my $report_plugin ( sort { $a->get_subtype cmp $b->get_subtype } @plugins )
	{
		my $plugin_cat = $report_plugin->get_subtype;
		$plugin_cat =~ s/^Report::([^:]+):?:?(.*)$/$1/g;

		# render top-category, if needed	
		if( $cat ne $plugin_cat )
		{
			$cat = $plugin_cat;
			$cat_ul = undef;

			$cat_li = $ul->appendChild( $self->repository->make_element( 'li' ) );
			$cat_li->appendChild( $self->repository->html_phrase( "Plugin/Screen/Report/$cat:title" ) );
		}

		if( EPrints::Utils::is_set( $2 ) )
		{
			# then we hit a sub-plugin eg. Screen::Report::$category::$report <- $2 == $report here
			if( !defined $cat_ul )
			{
				$cat_ul = $cat_li->appendChild( $self->repository->make_element( 'ul', class => 'ep_report_items' ) );
			}

			# also needs a link
			my $sub_li = $cat_ul->appendChild( $self->repository->make_element( 'li' ) );
			$sub_li->appendChild( $report_plugin->render_action_link );
		}
		else
		{
			$cat_ul = undef;
		}
	}

	return $ul;

}

sub render
{
	my( $self ) = @_;

print STDERR "Report::render \n"; 
	# if users access Screen::Report directly we want to display some sort of menu
	# where users can select viewable reports
	if( "EPrints::Plugin::".$self->get_id eq __PACKAGE__ )
	{
		return $self->render_splash_page;
	}

	my $repo = $self->repository;

	my $chunk = $repo->make_doc_fragment;

	$chunk->appendChild( $self->render_export_bar );

	my $items = $self->items;

	if( !defined $items || $items->count == 0 )
	{
		# No items message
	}

	my $item_ids = defined $items ? $items->ids : [];

	my $json = "[".join(',',@$item_ids)."]";

        my $url = $repo->current_url( host => 1 );
        my $parameters = URI->new;
        $parameters->query_form(
                $self->hidden_bits,
        );
        $parameters = $parameters->query;

	my $prefix = $self->param( 'datasetid' );

	# the main <div>
	my $container_id = sprintf( "ep_report_%s\_container", $self->get_report );

	$chunk->appendChild( $repo->make_javascript( <<"EOJ" ) );
document.observe("dom:loaded", function() {

	new EPrints_Screen_Report_Loader( {
		ids: $json,
		step: 20,
		prefix: '$prefix',
		url: '$url',
		parameters: '$parameters',
		container_id: '$container_id' 
	} ).execute();

});
EOJ

	$chunk->appendChild( $repo->make_element( 'div', class => 'ep_report_page', id => $container_id ) );

	return $chunk;
}


sub render_export_bar
{
	my( $self ) = @_;

print STDERR "Report::render_export_bar \n"; 
	my $repo = $self->repository;

	my $chunk = $repo->make_doc_fragment;

	my @plugins = $self->export_plugins;
	
	return $chunk unless( scalar( @plugins ) );

	my $form = $chunk->appendChild( $self->render_form );
	$form->setAttribute( method => "get" );
	my $select = $form->appendChild( $repo->render_option_list(
		name => 'export',
		values => [map { $_->get_subtype } @plugins],
		labels => {map { $_->get_subtype => $_->get_name } @plugins},
	) );
	$form->appendChild( 
		$repo->render_button(
			name => "_action_export",
			class => "ep_form_action_button",
			value => $repo->phrase( 'cgi/users/edit_eprint:export' )
	) );
	
	return $chunk;
}

### utility methods

# TODO should use "JSON" package
sub to_json
{
        my( $self, $object ) = @_;

	return "" if( !defined $object );

# UTF-8 issues:
#	return JSON->new->utf8(1)->encode( $object );

        if( ref( $object ) eq 'HASH' )
        {
                my @stuff;
                while( my( $k, $v ) = each( %$object ) )
                {
                        next if( !EPrints::Utils::is_set( $v ) );       # or 'null' ?
                        push @stuff, EPrints::Utils::js_string( $k ).':'.$self->to_json( $v )
                }
                return '{' . join( ",", @stuff ) . '}';
        }
        elsif( ref( $object ) eq 'ARRAY' )
        {
                my @stuff;
                foreach( @$object )
                {
                        next if( !EPrints::Utils::is_set( $_ ) );
                        push @stuff, $self->to_json( $_ );
                }
                return '[' . join( ",", @stuff ) . ']';
        }

        return EPrints::Utils::js_string( $object );
}

sub export_plugins
{
        my( $self ) = @_;

        my @plugin_ids = $self->repository->plugin_list(
                type => "Export",
                can_accept => "report/".$self->get_report,
                is_visible => "staff",
		is_advertised => 1,
        );
        
	my @plugins;
	foreach my $id ( @plugin_ids )
        {
                my $p = $self->repository->plugin( "$id" ) or next;
                push @plugins, $p;
        }

        return @plugins;
}

sub report_plugins
{
	my( $self ) = @_;

print STDERR "Report::report_plugins \n"; 
	# sf2 - can't list via type => "Search::Report" ? 
        my @plugin_ids = $self->repository->plugin_list(
                type => "Screen",
        );

        my @plugins;
	foreach my $id ( @plugin_ids )
        {
		next if( $id !~ /^Screen::Report::/ );	# note this also filters out $self (aka Screen::Report)

                my $p = $self->repository->plugin( "$id" );
		next if( !defined $p || !$p->can_be_viewed );

                push @plugins, $p;
        }

        return @plugins;
}


1;
