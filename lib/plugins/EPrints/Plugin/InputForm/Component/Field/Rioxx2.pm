package EPrints::Plugin::InputForm::Component::Field::Rioxx2;

use EPrints::Plugin::InputForm::Component::Field;

@ISA = ( "EPrints::Plugin::InputForm::Component::Field" );

use strict;

sub new
{
	my( $class, %opts ) = @_;

	my $self = $class->SUPER::new( %opts );

	$self->{name} = "RIOXX2";

	return $self;
}

sub render_content
{
	my( $self, $surround ) = @_;

	my $field = $self->{config}->{field}->{name};
	my $source = $self->rioxx2_plugin->field_config( $field )->{source};
	return $self->SUPER::render_content( $surround ) if ref($source) eq "" && $source =~ /\.$field/;

	my $repo = $self->repository;
	my $class = "rioxx2_override";
	my $basename = $self->{prefix} . "_$class";
	my $value = $self->{dataobj}->get_value( $self->{config}->{field}->{name} ) if $self->{dataobj};

	my $mapped_value = $self->rioxx2_plugin->value( $self->{dataobj}, $self->{config}->{field}->{name} );

	return $self->html_phrase( "content",
		mapped_value => $repo->xml->create_text_node( $mapped_value ),
		choose_container => $repo->xml->create_element( "div", id => $basename, class => $class ),
		use_mapping => $repo->render_noenter_input_field(
			type => "radio",
			value => "use_mapping",
			name => "$basename\_radio",
			checked => EPrints::Utils::is_set( $value ) ? undef : "checked"
		),
		use_override => $repo->render_noenter_input_field(
			type => "radio",
			value => "use_override",
			name => "$basename\_radio",
			checked => EPrints::Utils::is_set( $value ) ? "checked" : undef
		),
		input_container => $repo->xml->create_element( "div", id => $basename . "_input" ),
		input => $self->SUPER::render_content( $surround )
	);
}

sub validate
{
	my( $self ) = @_;

	return map { $self->repository->xml->create_text_node( $_ ) }
		$self->rioxx2_plugin->validate( $self->{dataobj}, $self->{config}->{field}->{name} );
}

sub rioxx2_plugin
{
	my( $self ) = @_;

	return $self->{rioxx2} if defined $self->{rioxx2};

	return $self->{rioxx2} = $self->repository->plugin( "Rioxx2Utils" );
}

1;
