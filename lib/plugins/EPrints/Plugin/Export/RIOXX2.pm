package EPrints::Plugin::Export::RIOXX2;

use base qw( EPrints::Plugin::Export::XMLFile );

use strict;

sub new
{
	my ($class, %params) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{accept} = [qw( dataobj/eprint )];
	$self->{name} = 'OAI-PMH RIOXX';
	$self->{metadataPrefix} = "rioxx";
	$self->{xmlns} = "http://docs.rioxx.net/schema/v1.0/",
	$self->{schemaLocation} = "http://docs.rioxx.net/schema/v1.0/rioxx.xsd";

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

	if ($eprint->exists_and_set('creators'))
	{
		foreach my $creator (@{$eprint->value('creators')})
		{
			my $id = $creator->{id};
			push @data, [
					'dc:creator',
					EPrints::Utils::make_name_string($creator->{name}),
					id => $id,
				];
		}
	}
	
	my @docs = $eprint->get_all_documents;
	if (@docs)
	{
		push @data, [
				'dc:identifier',
				$docs[0]->get_url,
			];
		if ($docs[0]->exists_and_set('mime_type'))
		{
			push @data, [
					'dc:format',
					$docs[0]->value('mime_type'),
				];
		}
		else
		{
			push @data, [
					'dc:format',
					$docs[0]->value('format'),
				];
		}
		if ($docs[0]->exists_and_set('license'))
		{
			push @data, [
					'dc:rights',
					$docs[0]->value('license'),
				];
		}
	}
	else
	{
		push @data, [
				'dc:identifier',
				$eprint->uri,
			];
	}

	if ($eprint->exists_and_set('language'))
	{
		push @data, [
				'dc:language',
				$eprint->value('language'),
			];
	}
	elsif (@docs && $docs[0]->exists_and_set('language'))
	{
		push @data, [
				'dc:language',
				$docs[0]->value('language'),
			];
	}

	if ($eprint->exists_and_set('issn'))
	{
		push @data, [
				'dc:source',
				$eprint->value('issn'),
			];
	}

	if ($eprint->exists_and_set('title'))
	{
		push @data, [
				'dc:title',
				$eprint->value('title'),
			];
	}

	if ($eprint->exists_and_set('date'))
	{
		push @data, [
				'dcterms:issued',
				$eprint->value('date'),
			];
	}

	if ($eprint->exists_and_set('funders'))
	{
		foreach my $funder (@{$eprint->value('funders')})
		{
			push @data, [
					'rioxxterms:funder',
					$funder,
				];
		}
	}

	if ($eprint->exists_and_set('projects'))
	{
		foreach my $project (@{$eprint->value('projects')})
		{
			push @data, [
					'rioxxterms:project',
					$project,
				];
		}
	}

	if ($eprint->exists_and_set('abstract'))
	{
		push @data, [
				'dc:description',
				$eprint->value('abstract'),
			];
	}

	if ($eprint->exists_and_set('publisher'))
	{
		push @data, [
				'dc:publisher',
				$eprint->value('publisher'),
			];
	}

	if ($eprint->exists_and_set('subjects'))
	{
		foreach my $subject (@{$eprint->value('subjects')})
		{
			push @data, [
					'dc:subject',
					$subject,
				];
		}
	}

	if ($eprint->exists_and_set('contributors'))
	{
		foreach my $person (@{$eprint->value('contributors')})
		{
			my $id = $person->{id};
			push @data, [
					'dc:contributor',
					EPrints::Utils::make_name_string($person->{name}),
					id => $id,
				];
		}
	}
	
	if ($eprint->exists_and_set('type'))
	{
		push @data, [
				'dc:type',
				$eprint->value('type'),
			];
	}

	for(qw( official_url id_number ))
	{
		if ($eprint->exists_and_set($_))
		{
			push @data, [
					'dc:relation',
					$eprint->value($_),
				];
		}
	}

	if ($eprint->exists_and_set('relation'))
	{
		foreach my $relation (@{$eprint->value('relation')})
		{
			push @data, [
					'dcterms:references',
					$relation->{uri},
				];
		}
	}

	my $f = $self->param('extra_fields');
	&$f($self, $eprint, \@data) if defined $f;

	for(@data)
	{
		$rioxx->appendChild($xml->create_data_element(@$_));
	}

	return $rioxx;
}

1;
