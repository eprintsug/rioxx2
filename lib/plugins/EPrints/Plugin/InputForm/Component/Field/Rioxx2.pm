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

	my $repo = $self->{repository};
	my $class = "rioxx2_override";
	my $basename = $self->{prefix} . "_$class";
	my $value = $self->{dataobj}->get_value( $self->{config}->{field}->{name} ) if $self->{dataobj};

	my $mapped_value = $repo->plugin( "Rioxx2Utils" )->value( $self->{dataobj}, $self->{config}->{field}->{name} );

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

	return $self->{repository}->plugin( "Rioxx2Utils" )->validate( $self->{dataobj}, $self->{config}->{field}->{name} );
}

1;
