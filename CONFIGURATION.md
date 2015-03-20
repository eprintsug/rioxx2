# RIOXX2 Plugin for EPrints: Configuration Guide

## Introduction

### Core RIOXX2 Fields

The RIOXX2 plugin adds 21 fields to the EPrints dataset, corresponding to the 21 fields in the [RIOXX v2.0 application profile](http://rioxx.net/v2-0-final/)

In EPrints, these fields are virtual, that is they do not exist in the database - the value of a particular RIOXX2 field for a given record is derived whenever the field is accessed:

    $eprint->value( "rioxx2_description" );

### RIOXX2 Datatype

The RIOXX2 plugin defines the new datatype MetaField::RIOXX2 for these fields. This datatype adds the following properties:

<table>
    <tr>
        <td>rioxx2_value (coderef)</td>
        <td>given an eprint (and document if available), returns the derived value of the field</td>
    </tr>
    <tr>
        <td>rioxx2_validate (coderef)</td>
        <td>given a value and an eprint, returns a list of validation problems - note: checking that "mandatory" fields (see rioxx2_required property) have a value is handled automatically by Metafield::RIOXX2::validate()</td>
    </tr>
    <tr>
        <td>rioxx2_required (string)</td>
        <td>specifies whether the field is mandatory or not - recognised values are mandatory, recommended and optional</td>
    </tr>
    <tr>
        <td>rioxx2_ns (string)</td>
        <td>the namespace prefix that should be used by the XML export</td>
    </tr>
</table>

### Non-Virtual RIOXX2 Fields

The RIOXX2 plugin also adds a number of non-virtual fields to the eprint dataset. These are fields for which either a value cannot be derived (no equivalent exists in the default EPrints schema) or the derived value is a "best guess" (see User Guide for examples).

These fields are recognisable by their "_input" suffix eg. rioxx2\_coverage\_input, rioxx2\_language\_input.

When $eprint->value( "rioxx2\_description" ) is called, MetaField::RIOXX2::get\_value() will:

* check whether a field called rioxx2\_description\_input exists, and if so return its value
* otherwise call the rioxx2\_description field's "rioxx2\_value" property and return its value (or undef if the field does not have this property)

### RIOXX2 Fields in the Workflow

The virtual RIOXX2 fields can be added to the deposit workflow, provided that a corresponding _input field is also defined (by default the plugin adds 11 virtual fields to the workflow in a separate "rioxx" stage):

     <component type="Field::RIOXX2"><field ref="rioxx2_dateAccepted" /></component>

The Field::RIOXX2 input component will render the field as follows:

* If the field has no rioxx\_value property, render the corresponding \_input field as normal
* Otherwise render an "override" option - that is, wrap the corresponding \_input field in a Yes/No input allowing the user to specify whether or not they want to override the value derived by the rioxx2\_value property. If the user clicks Yes, the corresponding \_input field will be revealed to accept the override value.

## Putting it into Practice - Configuration Examples

### I'm already capturing the date of acceptance

Edit archives/foo/cfg/workflows/eprint/default.xml and remove the rioxx2_dateAccepted field:

    --- default.xml.orig	2015-03-20 08:51:09.150507257 +0000
    +++ default.xml	2015-03-20 08:50:44.162382831 +0000
    @@ -292,7 +292,6 @@
         <component type="Field::RIOXX2"><field ref="rioxx2_type"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_coverage"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_language"/></component>
    -    <component type="Field::RIOXX2"><field ref="rioxx2_dateAccepted"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_free_to_read"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_license_ref"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_apc"/></component>

Then add the following to archives/foo/cfg/cfg.d/zzz\_rioxx\_overrides.pl:

    # add a rioxx2\_value property to the rioxx2\_dateAccepted field
    for( @{$c->{fields}->{eprint}} )
    {
        $_->{rioxx2_value} = "rioxx2_value_dateAccepted" if $_->{name} eq "rioxx2_dateAccepted";    
    }
    
    # derive the date of acceptance from your existing field
    $c->{rioxx2_value_dateAccepted} = sub {
    	my ( $eprint ) = @_; 
    
    	if( $eprint->is_set( "my_date_accepted" ) )
    	{
    		return $eprint->value( "my_date_accepted" );
    	}
    	return undef;
    };

### I'm not already capturing the date of acceptance - I want depositors to see the RIOXX2 Date Accepted field

Edit archives/foo/cfg/workflows/eprint/default.xml and move the rioxx2_dateAccepted field out of the rioxx stage.

    --- default.xml.orig	2015-03-20 08:45:15.184751723 +0000
    +++ default.xml	2015-03-20 08:44:12.272439765 +0000
    @@ -41,6 +41,8 @@
         <component><field ref="title" required="yes" input_lookup_url="{$config{rel_cgipath}}/users/lookup/title_duplicates" input_lookup_params="id={eprintid}&amp;dataset=eprint&amp;field=title"/></component>
         <component><field ref="abstract"/></component>
     
    +    <component type="Field::RIOXX2"><field ref="rioxx2_dateAccepted"/></component>
    +
         <epc:if test="type = 'monograph'">
           <component><field ref="monograph_type" required="yes"/></component>
         </epc:if>
    @@ -292,7 +294,6 @@
         <component type="Field::RIOXX2"><field ref="rioxx2_type"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_coverage"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_language"/></component>
    -    <component type="Field::RIOXX2"><field ref="rioxx2_dateAccepted"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_free_to_read"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_license_ref"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_apc"/></component>

### I want to use the RIOXX2 Projects field instead of the default EPrints Projects and Funders fields

Edit archives/foo/cfg/workflows/eprint/default.xml and replace the default projects and funders fields with the rioxx2_project field:

    --- default.xml.orig	2015-03-20 08:45:15.184751723 +0000
    +++ default.xml	2015-03-20 08:49:23.249981972 +0000
    @@ -239,8 +239,7 @@
           <field ref="related_url"/>
         </component>
     
    -    <component><field ref="funders"/></component>
    -    <component><field ref="projects"/></component>
    +    <component type="Field::RIOXX2"><field ref="rioxx2_project"/></component>
     
         <epc:if test="type = 'teaching_resource'">
           <component type="Field::Multi">
    @@ -297,7 +296,6 @@
         <component type="Field::RIOXX2"><field ref="rioxx2_license_ref"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_apc"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_author"/></component>
    -    <component type="Field::RIOXX2"><field ref="rioxx2_project"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_publication_date"/></component>
         <component type="Field::RIOXX2"><field ref="rioxx2_version"/></component>
       </stage></workflow>

If you already have records with projects and funders values, you will need to migrate these to the rioxx2\_project\_input field. For example you could add the following to archives/foo/cfg/cfg.d/zzz\_migrate\_projects.pl:

    $c->add_dataset_trigger( 'eprint', EPrints::Const::EP_TRIGGER_BEFORE_COMMIT, sub 
    {
            my( %args ) = @_; 
            my( $repo, $eprint, $changed ) = @args{qw( repository dataobj changed )};
    
            # if this is an existing record, initialise the rioxx2_project_input field
            if( !$eprint->is_set( "rioxx2_project_input" ) && ( $eprint->is_set( "projects" ) || $eprint->is_set( "funders" ) ) )
            {
    		my $mf = $eprint->dataset->field( "rioxx2_project" );
                    $eprint->set_value( "rioxx2_project_input", $mf->get_value( $eprint ) );
            }
    }, priority => 100 );

And then run:

    bin/epadmin recommit foo

Check the rioxx2\_project\_input values in the database before proceeding.

Finally, remove the archives/foo/cfg/cfg.d/zzz\_migrate\_projects.pl and add the following to archives/foo/cfg/cfg.d/zzz\_rioxx\_overrides.pl:

    # remove rioxx2_value property from the rioxx2_project field
    for( @{$c->{fields}->{eprint}} )
    {
        $_->{rioxx2_value} = undef if $_->{name} eq "rioxx2_project";    
    }

### Need more examples?

Please [raise an issue](https://github.com/eprintsug/rioxx2/issues) or [contact the author](https://github.com/drtjmb).
