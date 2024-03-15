package EPrints::Plugin::InputForm::Component::Field::RIOXX2;

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

sub parse_config
{
	my( $self, $config_dom ) = @_;

	$self->SUPER::parse_config( $config_dom );

	return if scalar @{$self->{problems}};

	unless( defined $self->_input_field )
	{
		push @{$self->{problems}}, $self->repository->html_phrase( "Plugin/InputForm/Component/Field/RIOXX2:error_missing_input",
			ref => $self->repository->xml->create_text_node( $self->{config}->{field}->name ),
			xml => $self->repository->xml->create_text_node( $self->{repository}->xml->to_string( $config_dom ) )
		);
	}
}

sub _input_field
{
	my( $self ) = @_;

	if( $self->{dataobj}->dataset->has_field( $self->{config}->{field}->name . "_input" ) )
	{
		return $self->{dataobj}->dataset->field( $self->{config}->{field}->name . "_input" );
	}
	return;
}

sub render_content
{
	my( $self, $surround ) = @_;

	my $field = $self->{config}->{field};
	local $self->{config}->{field} = my $override_field = $self->_input_field;

	unless( $field->property( "rioxx2_value" ) )
	{
		return $self->SUPER::render_content( $surround );
	}

	my $repo = $self->repository;
	my $class = "rioxx2_override";
	my $basename = $self->{prefix} . "_$class";

	my $override_value = $self->{dataobj}->value( $override_field->name );

	return $self->html_phrase( "content",
		mapped_value => $field->render_value( $repo, undef, undef, undef, $self->{dataobj}, 1 ),
		choose_container => $repo->xml->create_element( "div", id => $basename, class => $class ),
		use_mapping => $repo->render_noenter_input_field(
			type => "radio",
			value => "use_mapping",
			name => "$basename\_radio",
			checked => EPrints::Utils::is_set( $override_value ) ? undef : "checked"
		),
		use_override => $repo->render_noenter_input_field(
			type => "radio",
			value => "use_override",
			name => "$basename\_radio",
			checked => EPrints::Utils::is_set( $override_value ) ? "checked" : undef
		),
		input_container => $repo->xml->create_element( "div", id => $basename . "_input" ),
		input => $self->SUPER::render_content( $surround )
	);
}

sub update_from_form
{
	my( $self, $processor ) = @_;

	local $self->{config}->{field} = $self->_input_field;
	return $self->SUPER::update_from_form;
}


sub validate
{
	my( $self ) = @_;

	return $self->{config}->{field}->validate( $self->repository, $self->{config}->{field}->get_value( $self->{dataobj} ) );
}

sub is_required
{
	my( $self ) = @_;

	return $self->{config}->{field}->is_mandatory( $self->{dataobj} );
}

1;
