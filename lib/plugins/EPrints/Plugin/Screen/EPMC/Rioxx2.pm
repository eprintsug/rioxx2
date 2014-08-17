package EPrints::Plugin::Screen::EPMC::Rioxx2;

@ISA = ( 'EPrints::Plugin::Screen::EPMC' );

use strict;
# Make the plug-in
sub new
{
      my( $class, %params ) = @_;

      my $self = $class->SUPER::new( %params );

      $self->{actions} = [qw( enable disable )];
      $self->{disable} = 0; # always enabled, even in lib/plugins

      $self->{package_name} = 'rioxx2';

      return $self;
}

=item $screen->action_enable( [ SKIP_RELOAD ] )

Enable the L<EPrints::DataObj::EPM> for the current repository.

If SKIP_RELOAD is true will not reload the repository configuration.

=cut

sub action_enable
{
        my( $self, $skip_reload ) = @_;

        $self->SUPER::action_enable( $skip_reload );
        my $repo = $self->{repository};


my $xml = '
 <workflow xmlns="http://eprints.org/ep3/workflow" xmlns:epc="http://eprints.org/ep3/control">
       <flow>
               <stage ref="rioxx2"/>
       </flow>
       <stage name="rioxx2">
               <component>
                       <field ref="title" required="yes" />
                       <field ref="rioxx2_coverage" />
                       <field ref="rioxx2_language" />
                       <field ref="rioxx2_date_accepted" />
                       <field ref="rioxx2_freetoread" />
                       <field ref="rioxx2_license" />
                       <field ref="rioxx2_apc" />
                       <field ref="rioxx2_project" />
                       <field ref="rioxx2_publication_date" />
                       <field ref="rioxx2_type" />
                       <field ref="rioxx2_version" />
               </component>
       </stage>
</workflow>
';



	my $filename = $repository->config( "config_path" )."/workflows/eprint/default.xml";

        EPrints::XML::add_to_xml( $filename, $xml, $self->{package_name} );


        $self->reload_config if !$skip_reload;
}

=item $screen->action_disable( [ SKIP_RELOAD ] )

Disable the L<EPrints::DataObj::EPM> for the current repository.

If SKIP_RELOAD is true will not reload the repository configuration.

=cut

sub action_disable
{
        my( $self, $skip_reload ) = @_;

        $self->SUPER::action_disable( $skip_reload );
        my $repo = $self->{repository};

	my $filename = $repository->config( "config_path" )."/workflows/eprint/default.xml";
        EPrints::XML::remove_package_from_xml( $filename, $self->{package_name} );

        $self->reload_config if !$skip_reload;
}

