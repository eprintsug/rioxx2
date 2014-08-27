=head1 NAME

EPrints::Plugin::Screen::EPrint::RIOXX2

=cut

package EPrints::Plugin::Screen::EPrint::RIOXX2;

our @ISA = ( 'EPrints::Plugin::Screen::EPrint' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{appears} = [
		{
			place => "eprint_view_tabs",
			position => 250,
		},
	];

	my $session = $self->{session};
	if( $session && $session->get_online )
	{
		$self->{title} = $session->make_element( "span" );
		$self->{title}->appendChild( $self->SUPER::render_tab_title );
	}

	return $self;
}

sub DESTROY
{
	my( $self ) = @_;

	if( $self->{title} )
	{
		$self->{session}->xml->dispose( $self->{title} );
	}
}

sub render_tab_title
{
	my( $self ) = @_;

	# Return a clone otherwise the DESTROY above will double-dispose of this
	# element when it is disposed by whatever called us
	return $self->{session}->xml->clone( $self->{title} );
}

sub can_be_viewed
{
	my( $self ) = @_;
		
	return $self->allow( "eprint/details" );
}

sub _render_name_maybe_with_link
{
	my( $self, $eprint, $field ) = @_;

	my $r_name = $field->render_name( $eprint->{session} );

	return $r_name if !$self->edit_ok;

	my $name = $field->get_name;
	my $field_type = $field->get_type;
	
	my $stage = $self->_find_stage( $eprint, $name );

	return $r_name if( !defined $stage );

	my $url = "?eprintid=".$eprint->get_id."&screen=".$self->edit_screen_id."&stage=$stage#$name";
	my $link = $eprint->{session}->render_link( $url );
	$link->setAttribute( title => $self->phrase( "edit_field_link",
			field => $self->{session}->xhtml->to_text_dump( $r_name )
		) );
	$link->appendChild( $r_name );
	return $link;
}

sub edit_screen_id { return "EPrint::Edit"; }

sub edit_ok
{
	my( $self ) = @_;

	return $self->{edit_ok};
}


sub _find_stage
{
	my( $self, $eprint, $name ) = @_;

	my $workflow = $self->workflow;

	return  $workflow->{field_stages}->{$name};

	# if the stage is not found we could try and find the source field
	# as this does not always work it would probably be confusing
	# Probably only makes sense if we explicity record the source field
	# in the rioxx2 field.
	#if ( $name =~ /rioxx2_(\w+)/ )
	#{
	#	return $workflow->{field_stages}->{$1};
	#}
}

sub render
{
	my( $self ) = @_;

	my $repo = $self->{repository};
        my $xml = $repo->xml;
        my $xhtml = $repo->xhtml;
	my $eprint = $self->{processor}->{eprint};

	my @labels;
	push @labels, $self->html_phrase( "fields" );
	push @labels, $self->html_phrase( "xml" );

	my @contents;
	push @contents, $self->render_fields();
	push @contents, $self->render_xml();

	my $id_prefix = "rioxx2_view";
	my $current = $repo->param( "${id_prefix}_current" );
	$current = 0 if !defined $current;

	my $page = $repo->make_doc_fragment;
	$page->appendChild( $repo->xhtml->tabs(
		\@labels,
		\@contents,
		basename => $id_prefix,
		current => $current,
		) );

	$page->appendChild( $self->render_export_button( $eprint ) );

	return $page;
}

sub render_fields
{
	my( $self ) = @_;

	my $eprint = $self->{processor}->{eprint};
	my $session = $eprint->{session};
	my $workflow = $self->workflow;

	my $page = $session->make_doc_fragment;

	$self->{edit_ok} = $self->could_obtain_eprint_lock;
	$self->{edit_ok} &&= $self->allow( "eprint/edit" );

	my $rows = [];
	my $stage = "rioxx2";
	my @fields = grep { $_->type =~ /^rioxx2$/ } $eprint->get_dataset->get_fields;
	foreach my $field ( @fields )
	{
		my $name = $field->get_name();

		my $r_name = $self->_render_name_maybe_with_link( $eprint, $field );

		if( !$field->isa( "EPrints::MetaField::Subobject" ) )
		{
			push @$rows, $session->render_row(
				$r_name,
				$eprint->render_value( $field->get_name(), 1 ) );
		}
	}


	my $has_problems = 0;

	my $edit_screen = $session->plugin(
		"Screen::".$self->edit_screen_id,
		processor => $self->{processor} );

	my $table = $session->make_element( "table",
			border => "0",
			cellpadding => "3" );
	$page->appendChild( $table );

	my( $tr, $th, $td );

	my $url = URI->new( $session->current_url );
	$url->query_form(
		screen => $self->edit_screen_id,
		eprintid => $eprint->id,
		stage => $stage
	);

	$tr = $session->make_element( "tr" );
	$table->appendChild( $tr );
	$th = $session->make_element( "th", colspan => 2, class => "ep_title_row" );

	$tr->appendChild( $th );

	my $title = $session->html_phrase( "metapage_title_$stage" );
	my $table_inner = $session->make_element( "table", style=>'width:100%' );
	my $tr_inner = $session->make_element( "tr" );
	my $td_inner_1 = $session->make_element( "td", style=>'text-align:left;margin-right:1em' );
	$th->appendChild( $table_inner );
	$table_inner->appendChild( $tr_inner );
	$tr_inner->appendChild( $td_inner_1 );
	$td_inner_1->appendChild( $title );
	if( $self->edit_ok )
	{
		my $td_inner_2  = $session->make_element( "td",style=>'text-align:right;font-size:80%' );
		$tr_inner->appendChild( $td_inner_2 );
		$td_inner_2->appendChild( $self->render_edit_button( $stage ) );
	}

	$tr = $session->make_element( "tr" );
	$table->appendChild( $tr );
	$td = $session->make_element( "td", colspan => 2 );
	$tr->appendChild( $td );
#	my @problems = $stage->validate( $self->{processor} );
#	if( @problems )
#	{
#		$has_problems = 1;
#		$td->appendChild(
#			$self->render_stage_warnings( $stage, @problems ) );
#	}

	foreach $tr (@$rows)
	{
		$table->appendChild( $tr );
	}

	if( $has_problems )
	{
		my $span = $self->{title};
		$span->setAttribute( style => "padding-left: 20px; background: url('".$session->current_url( path => "static", "style/images/warning-icon.png" )."') no-repeat;" );
	}

	$tr = $session->make_element( "tr" );
	$table->appendChild( $tr );
	$td = $session->make_element( "td", colspan => 2 );
	$tr->appendChild( $td );

	return $page;
}

sub render_xml
{
	my( $self ) = @_;

print STDERR "render_xml\n";
	my $repo = $self->{repository};
	my $eprint = $self->{processor}->{eprint};

        my $plugin = $repo->plugin( "Export::RIOXX2" ); 
	my $page = $repo->make_doc_fragment;
	
	my $output = $plugin->xml_dataobj( $eprint ); 

print STDERR "output: ".$output->toString."\n";

	my $div = $page->appendChild( $repo->xml->create_element( "div" ) );
	$div->appendChild( $self->html_phrase( "xmlblock", xml=>$self->render_xml_tree( $repo, $output, 0, 600 ) ) );

	return $page;
}




sub render_edit_button
{
	my( $self, $stage ) = @_;

	my $session = $self->{session};

	my $div = $session->make_element( "div" );

	local $self->{processor}->{stage} = $stage;

	my $screen = $session->plugin( "Screen::".$self->edit_screen_id,
			processor => $self->{processor},
		);
	return $div if !defined $screen; # No Edit screen plugin available

	my $button = $self->render_action_button({
		screen => $screen,
		screen_id => "Screen::".$self->edit_screen_id,
		hidden => [qw( eprintid stage )],
	});
	$div->appendChild( $button );

	return $div;
}

sub render_stage_warnings
{
	my( $self, $stage, @problems ) = @_;

	my $session = $self->{session};

	my $ul = $session->make_element( "ul" );
	foreach my $problem ( @problems )
	{
		my $li = $session->make_element( "li" );
		$li->appendChild( $problem );
		$ul->appendChild( $li );
	}
	$self->workflow->link_problem_xhtml( $ul, $self->edit_screen_id, $stage );

	return $session->render_message( "warning", $ul );
}


sub render_export_button
{
        my( $self, $eprint ) = @_;

        my $repo = $self->{session};
        my $xml = $repo->xml;
        my $xhtml = $repo->xhtml;
	my $user = $repo->current_user;
	my $staff = $user->get_type eq "editor" || $user->get_type eq "admin";

        my $frag = $xml->create_document_fragment;
        my $plugin = $repo->plugin( "Export::RIOXX2" ); 

	return $frag unless $plugin;

        my $uri = $repo->config( "http_cgiurl" ) . "/export_redirect"; 
        my $form = $repo->render_form( "GET", $uri );
        $frag->appendChild( $form );
        $form->appendChild( $xhtml->hidden_field( dataset => $eprint->dataset->id ) );
        $form->appendChild( $xhtml->hidden_field( dataobj => $eprint->id ) );
        $form->appendChild( $xhtml->hidden_field( format => $plugin->get_subtype ) );
                                        
        $form->appendChild(
                $xml->create_element( "input",
                        type => "submit",
                        value => $repo->phrase( "lib/searchexpression:export_button" ),
                        class => "ep_form_action_button"
                )
        ); 

        return $frag;
}       


#XML render based on History.pm
sub render_xml_tree
{
	my( $self, $session, $domtree, $indent, $width ) = @_;

	if( EPrints::XML::is_dom( $domtree, "Text" ) )
	{
		my $v = $domtree->nodeValue;
		if( $v=~m/^[\s\r\n]*$/ )
		{
			return $session->make_doc_fragment;
		}
		my $r = $session->make_text( ("  "x$indent).$v."\n" );
		return $r;
	}

	if( EPrints::XML::is_dom( $domtree, "Element" ) )
	{
		my $t = '';
		my $justtext = 1;

		foreach my $cnode ( $domtree->getChildNodes )
		{
			if( EPrints::XML::is_dom( $cnode,"Element" ) )
			{
				$justtext = 0;
				last;
			}
			if( EPrints::XML::is_dom( $cnode,"Text" ) )
			{
				$t.=$cnode->nodeValue;
			}
		}
		my $name = $domtree->nodeName;
		my $f = $session->make_doc_fragment;
		my $padder;
		if( $justtext )
		{
			my $offset = $indent*2+length($name)+2;
			my $endw = length($name)+3;
			$f->appendChild( $session->make_text( "  "x$indent ) );
			$t = "" if( $t =~ m/^[\s\r\n]*$/ );
			$f->appendChild( $session->make_text( "<$name>" ) );
			$f->appendChild( mktext( $session, $t, $offset, $endw, $width ) );
			$f->appendChild( $session->make_text( "</$name>\n" ) );
		}
		else
		{
			$f->appendChild( $session->make_text( "  "x$indent ) );
			$f->appendChild( $session->make_text( "<$name>\n" ) );
	
			foreach my $cnode ( $domtree->getChildNodes )
			{
				my( $sub, $padsub ) = $self->render_xml_tree( $session,$cnode, $indent+1, $width );
				$f->appendChild( $sub );
			}

			$f->appendChild( $session->make_text( "  "x$indent ) );
			$f->appendChild( $session->make_text( "</$name>\n" ) );
		}
		return $f;
	}
	return( $session->make_text( "eh?:".ref($domtree) ), $session->make_doc_fragment );
}



sub _mktext
{
	my( $session, $text, $offset, $endw, $width ) = @_;

	return () unless length( $text );

	my $lb = chr(8626);
	my @bits = split(/[\r\n]/, $text );
	my @b2 = ();
	
	foreach my $t2 ( @bits )
	{
		while( $offset+length( $t2 ) > $width )
		{
			my $cut = $width-1-$offset;
			push @b2, substr( $t2, 0, $cut ).$lb;
			$t2 = substr( $t2, $cut );
			$offset = 0;
		}
		if( $offset+$endw+length( $t2 ) > $width )
		{
			push @b2, $t2.$lb, "";
		}
		else
		{
			push @b2, $t2;
		}
	}

	return @b2;
}

sub mktext
{
	my( $session, $text, $offset, $endw, $width ) = @_;

	my @bits = _mktext( $session, $text, $offset, $endw, $width );

	return $session->make_text( join( "\n", @bits ) );
}



1;


