=head1 NAME

EPrints::Plugin::InputForm::Component::Field::Rioxx2

=cut

package EPrints::Plugin::InputForm::Component::Field::Rioxx2;

use EPrints::Plugin::InputForm::Component::Field;

@ISA = ( "EPrints::Plugin::InputForm::Component::Field" );

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );

	$self->{name} = "Rioxx2";
	$self->{visible} = "all";

	$self->{actions} = [qw/ create /];

	return $self;
}

sub allow_create
{
	my ( $self ) = @_;

	return 1;
}

sub action_create
{
	my( $self ) = @_;

print STDERR "Rioxx2::action_create\n";
}
	
sub update_from_form
{
	my( $self, $processor ) = @_;

print STDERR "Rioxx2::update_from_form called\n";
	my $field = $self->{config}->{field};
	my $value = $field->form_value( $self->{session}, $self->{dataobj}, $self->{prefix} );
	$self->{dataobj}->set_value( $field->{name}, $value );
	return;
}

sub render_title
{
	my( $self, $surround ) = @_;

	my $reports = $self->{repository}->config( "reports" );
	my $rioxx_map = $reports->{rioxx2};
	return $self->SUPER::render_title( $surround ) unless $rioxx_map;

	my $repo = $self->{repository};
	my $xml = $repo->xml;
	my $title = $self->{config}->{field}->render_name( $repo );
	$title->appendChild( $xml->create_text_node(" (override)") );
	
	return $title;
}

sub render_content
{
	my( $self, $surround ) = @_;

	my $repo = $self->{repository};
print STDERR "Rioxx2::render_content ###### \n";
	my $dataobj = $self->{dataobj};
	my $reports = $self->{repository}->config( "reports" );
	my $rioxx_map = $reports->{rioxx2};
	return $self->SUPER::render_content( $surround ) unless $rioxx_map;

	my $dataset = $self->{dataobj}->dataset;
	my $report_field_name = $dataset->base_id.".".$self->{config}->{field}->name;
print STDERR "field name [".$self->{config}->{field}->name."] [$report_field_name]\n";
	my $default_value;
	my $value;
	foreach my $t ( keys $rioxx_map->{'mappings'} )
	{
		my $map_field = $rioxx_map->{'mappings'}->{$t};
		if ( $map_field eq $report_field_name )
		{
			# Get the default value for this field from the 
			# rioxx2 report config
			my $default = $rioxx_map->{'defaults'}->{$t}; 
			if ( $default )
			{
				if ( "CODE" eq ref $default )
				{
					$default_value = $default->($self, { eprint => $dataobj, } );
				}
				else
				{
					$default_value = $default;
				}
			}
			else
			{
				$default_value = $self->{default};
			}
			# if there is a value for this field the use it otherwise use the default.
			if ( $dataobj->is_set( $self->{config}->{field}->name ) )
			{
				$value = $dataobj->get_value( $self->{config}->{field}->name )
			}
			else
			{
				$value = $default_value;
			}
	
			last;
		}
	}
print STDERR "value[".$value."] default[".Data::Dumper::Dumper( $default_value )."]###\n";
	
	my $xml = $repo->xml;
	my $frag = $xml->create_document_fragment;
	my $table = $frag->appendChild( $xml->create_element( "table" ) );
	my $tr1 = $table->appendChild( $xml->create_element( "tr" ) );
	my $tr2 = $table->appendChild( $xml->create_element( "tr" ) );
	my $td11 = $tr1->appendChild( $xml->create_element( "td" ) );
	my $td12 = $tr1->appendChild( $xml->create_element( "td" ) );
	my $td21 = $tr2->appendChild( $xml->create_element( "td" ) );
	my $td22 = $tr2->appendChild( $xml->create_element( "td" ) );

	my $default_value_str = $default_value;
	$default_value_str = join(", ", @$default_value ) if 'ARRAY' eq ref $default_value;
	my $default_value_html = $xml->create_text_node( $default_value_str );
	$td11->appendChild ( $self->html_phrase( "default_for_field" ) );
	$td12->appendChild ( $default_value_html );
	$td21->appendChild ( $self->html_phrase( "override_for_field" ) );

	$td22->appendChild( $self->{config}->{field}->render_input_field( 
			$repo, 
			$value, 
			$dataobj->get_dataset,
			0, # staff mode should be detected from workflow
			undef,
			$self->{dataobj},
			$self->{prefix},
 	) );
#	my $v_selection = $xml->create_element( "input",
#                type => "radio",
#                name => "override",
#                value => "use_override",
#                ($value eq $default_value ? (checked => "checked") : ()) );
#	$v_selection->appendChild( $self->html_phrase( "select_default" ) );
	
#	my $d_selection = $xml->create_element( "input",
#                type => "radio",
#                name => "override",
#                value => "use_default",
#                ($value eq $default_value ? () : (checked => "checked") ) );
#	$d_selection->appendChild( $self->html_phrase( "select_override" ) );
#	$frag->appendChild( $xml->create_element( "br") );
#	$frag->appendChild( $d_selection );
#	$frag->appendChild( $v_selection );

	$frag->appendChild( $repo->make_javascript( <<EOJ ) );
new Component_Field ('$self->{prefix}');
EOJ

	return $frag;
}



sub render_content_mod
{
	my( $self, $surround ) = @_;
	my $session = $self->{session};
print STDERR "Rioxx2::render_content_mod called for [".$self->{config}->{field}->{name} ."]\n";
	
	my $value;
	if( $self->{dataobj} )
	{
		$value = $self->{dataobj}->get_value( $self->{config}->{field}->{name} );
	}
	else
	{
		$value = $self->{default};
	}

	my $frag = $session->make_doc_fragment;

	$frag->appendChild( $self->{config}->{field}->render_input_field( 
			$session, 
			$value, 
			$self->{dataobj}->get_dataset,
			0, # staff mode should be detected from workflow
			undef,
			$self->{dataobj},
			$self->{prefix},
 	) );

	$frag->appendChild( $session->make_javascript( <<EOJ ) );
new Component_Field ('$self->{prefix}');
EOJ
	my %buttons = (
		create => $self->phrase( "action:create:title" ),
		_order => [ "create", ]
	);

	my $form = $session->render_form( "GET" );
#	$form->appendChild( 
#		$session->render_hidden_field ( "screen", "NewUser" ) );		
#	my $ds = $session->dataset( "user" );
#	my $username_field = $ds->get_field( "username" );
#	my $usertype_field = $ds->get_field( "usertype" );
#	my $div = $session->make_element( "div", style=>"margin-bottom: 1em" );
#	$div->appendChild( $username_field->render_name( $session ) );
#	$div->appendChild( $session->make_text( ": " ) );
#	$div->appendChild( 
#		$session->make_element( 
#			"input",
#			"maxlength"=>"255",
#			"name"=>"username",
#			"id"=>"username",
#			"class"=>"ep_form_text",
#			"size"=>"20", ));
#	$form->appendChild( $div );
	$form->appendChild( $session->render_action_buttons( %buttons ) );
	
	$frag->appendChild( $form );


print STDERR "returning[".$frag->toString."]\n";
	return $frag;
}



1;


