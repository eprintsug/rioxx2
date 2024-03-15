package EPrints::MetaField::RIOXX2;

@ISA = qw( EPrints::MetaField );

use EPrints::Const qw( :metafield );

use strict;

sub is_virtual { 1 }

sub get_value
{
	my( $self, $object, $ignore_override ) = @_;

	if( !$ignore_override && $object->exists_and_set( $self->name . "_input" ) )
	{
		return $object->value( $self->name . "_input" );
	}

	# will return undef if property not defined
	return $self->call_property( "rioxx2_value", $object, $self->{repository}->call( [qw( rioxx2 select_document )], $object ) );
}

sub render_value
{
	my( $self, $repo, undef, undef, undef, $object, $ignore_override ) = @_;

	my $value = $self->get_value( $object, $ignore_override );

	return $repo->xml->create_text_node( $self->_flatten( $value ) );
}

sub _flatten
{
	my( $self, $value ) = @_;

	if( ref( $value ) eq "HASH" )
	{
		return join( ", ", map { "\u$_: " . $self->_flatten( $value->{ $_ } ) } sort keys %$value );
	}
	elsif( ref( $value ) eq "ARRAY" )
	{
		return join( "; ", map { $self->_flatten( $_ ) } @$value );
	}
	else
	{
		return $value;
	}
}

sub validate
{
	my( $self, $repo, $value, $object ) = @_;

	my @problems = $self->SUPER::validate( $repo, $value, $object );

	if( EPrints::Utils::is_set( $value ) && $self->has_property( "rioxx2_validate" ) )
	{
		push @problems, $self->call_property( "rioxx2_validate", $repo, $value, $object );
	}

	if( $self->is_mandatory( $object ) && !EPrints::Utils::is_set( $value ) )
	{
		push @problems, $repo->html_phrase( "rioxx2_validate_" . $self->name . ":not_done_field" );
	}

	return @problems;
}

sub is_mandatory
{
	my( $self, $object ) = @_;

	return $self->get_required( $object ) eq "mandatory";
}

sub get_required
{
	my( $self, $object ) = @_;

	my $v = $self->property( "rioxx2_required" );

	if( ref( $v ) eq "CODE" )
	{
		return $self->call_property( "rioxx2_required", $object );
	}

	return $v;
}

sub render_required
{
	my( $self, $object ) = @_;

	my $v = $self->get_required( $object );

	return $self->{repository}->html_phrase( "lib/metafield/property:rioxx2_required:$v" );
}

sub get_property_defaults
{
	my( $self ) = @_;

	my %defaults = $self->SUPER::get_property_defaults;

	$defaults{rioxx2_value} = EP_PROPERTY_UNDEF;
	$defaults{rioxx2_validate} = EP_PROPERTY_UNDEF;
	$defaults{rioxx2_required} = EP_PROPERTY_REQUIRED;
	$defaults{rioxx2_ns} = EP_PROPERTY_REQUIRED;

	return %defaults;
}

sub to_sax
{
}

1;
