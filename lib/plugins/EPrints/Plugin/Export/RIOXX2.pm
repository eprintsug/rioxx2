package EPrints::Plugin::Export::RIOXX2;

use base qw( EPrints::Plugin::Export::XMLFile );

use strict;

sub new
{
	my ($class, %params) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{accept} = [qw( dataobj/eprint )];
	$self->{name} = 'RIOXX2 XML';
	$self->{metadataPrefix} = "rioxx2";
	$self->{xmlns} = "http://docs.rioxx.net/schema/v2.0/",
	$self->{schemaLocation} = "http://docs.rioxx.net/schema/v2.0/rioxx.xsd";

	return $self;
}

sub output_dataobj
{
	my ($self, $dataobj, %opts) = @_;

	my $r = "";
	my $f = $opts{fh} ? sub { print {$opts{fh}} @_ } : sub { $r .= $_[0] };

	&$f($self->repository->xml->to_string(
		$self->xml_dataobj($dataobj),
		indent => 1,
	));

	return $r;
}

sub xml_dataobj
{
	my ($self, $eprint) = @_;

	my $repo = $self->repository;
	my $xml = $repo->xml;

	my $rioxx = $xml->create_element('rioxx',
		'xmlns' => $self->param('xmlns'),
		'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
		'xmlns:dcterms' => "http://purl.org/dc/terms/",
		'xmlns:rioxxterms' => "http://docs.rioxx.net/schema/v1.0/rioxxterms/",
        	'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
		'xsi:schemaLocation' => $self->param('xmlns')." ".$self->param('schemaLocation'),
	);

	my @data;

	foreach my $field ( grep { $_->name =~ /^rioxx2_/ && $_->name !~ /_input$/ && $_->is_virtual } $eprint->dataset->get_fields ) # TODO UGH
	{
		$field->name =~ /^rioxx2_(.*)$/;
		
		my $value = $field->get_value( $eprint );
		$value = [ $value ] unless ref( $value ) eq "ARRAY";

		for( @$value )
		{
			next unless EPrints::Utils::is_set( $_ );
			if( ref( $_ ) eq "" )
			{
				push @data, [
					$field->property( "rioxx2_ns" ) . ":" . $1,
					$_,
				];
			}
			elsif( ref( $_ ) eq "HASH" )
			{
				my %copy = %$_;
				push @data, [
					$field->property( "rioxx2_ns" ) . ":" . $1,
					delete $copy{$1},
					%copy,
				];
			}
		}
	}

	for(@data)
	{
		$rioxx->appendChild($xml->create_data_element(@$_));
	}

	return $rioxx;
}

1;
