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
			position => 2500,
		},
	];

	return $self;
}

sub can_be_viewed
{
	my( $self ) = @_;
		
	return $self->allow( "eprint/details" );
}

sub render
{
	my( $self ) = @_;

	my $repo = $self->{repository};
	my $page = $repo->xml->create_element( "div" ); # wrapper

	my( $problems, $recommended, $optional ) = $self->validate_fields;

	my $message;
	if( scalar @$problems )
	{
		$message = $repo->render_message( "warning", $self->html_phrase( "non_compliant" ) );
	}
	else
	{
		$message = $repo->render_message( "message", $self->html_phrase( "compliant" ) );
	}
	$page->appendChild( $self->html_phrase( "intro", message => $message, document => $self->render_document ) );

	$page->appendChild( $self->render_problems( undef, @$problems ) );
	$page->appendChild( $self->render_problems( "recommended", @$recommended ) );
	$page->appendChild( $self->render_problems( "optional", @$optional ) );

	$self->workflow->link_problem_xhtml( $page, $self->edit_screen_id );

	$page->appendChild( $self->render_export );

	return $page;

}

sub validate_fields
{
	my( $self ) = @_;

	my( @problems, @recommended, @optional );

	my $repo = $self->{repository};
	my $eprint = $self->{processor}->{eprint};

	my @fields = grep { $_->type =~ /^rioxx2$/ } $eprint->get_dataset->get_fields;
	foreach my $field ( @fields )
	{
		if( my @p = $field->validate( $repo, $eprint->value( $field->get_name ), $eprint ) )
		{
			for( @p )
			{
				push @problems, { field => $field, problem => $_ };
			}
			next;
		}

		next if $eprint->is_set( $field->get_name );

		my $info = {
			field => $field,
			problem => ( $repo->html_phrase( "rioxx2_validate_" . $field->get_name . ":not_done_field" ) ),
		};
		$field->get_required( $eprint ) eq "recommended" ? push @recommended, $info : push @optional, $info;
	}
	return \@problems, \@recommended, \@optional;
}

sub render_document
{
	my( $self ) = @_;

	my $repo = $self->{repository};
	my $doc = $repo->call( [qw( rioxx2 select_document )], $self->{processor}->{eprint} );

	if( $doc )
	{
		return $self->html_phrase( "render_document", icon => $doc->render_icon_link, citation => $doc->render_citation );
	}
	return $self->html_phrase( "render_no_document" );
}

sub render_problems
{
	my( $self, $id, @problems ) = @_;

	my $repo = $self->{repository};
	my $frag = $repo->xml->create_document_fragment;
	return $frag unless @problems;

	my $p = $repo->xml->create_document_fragment;
	for( @problems )
	{
		$p->appendChild( $self->html_phrase( "render_problem",
			field => $_->{field}->render_name,
			help => $_->{field}->render_help,
			problem => $_->{problem},
		) );
	}
	$frag = $self->html_phrase( "render_problems", problems => $p );

	return $frag unless defined $id;

	return EPrints::Box::render(
		id => $id,
		session => $repo,
		title => $self->html_phrase( $id, n => $repo->xml->create_text_node( scalar @problems ) ),
		content => $frag,
		collapsed => "true",
	);
}

sub render_export
{
	my( $self ) = @_;

	my $repo = $self->{repository};
	my $plugin = $repo->plugin( "Export::RIOXX2" );

	my $link = $repo->render_link( $plugin->dataobj_export_url( $self->{processor}->{eprint} ), target => "_blank" );

	return $self->html_phrase( "export", link => $link );
}

sub edit_screen_id { return "EPrint::Edit"; }

1;
