$c->{plugins}{"Screen::Report"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::Rioxx2"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::Rioxx2::Articles"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::Example"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::Example::Articles"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::Example::ConferenceItems"}{params}{disable} = 0;

$c->{plugins}{'Export::RIOXX2'}{params}{disable} = 0;
$c->{plugins}{"Export::Report"}{params}{disable} = 0;
$c->{plugins}{"Export::Report::CSV"}{params}{disable} = 0;
$c->{plugins}{"Export::Report::CSV::Example"}{params}{disable} = 0;
$c->{plugins}{"Export::Report::CSV::Rioxx2"}{params}{disable} = 0;

$c->{plugins}{"Screen::EPrint::RIOXX2"}{params}{disable} = 0;

$c->{plugins}{'InputForm::Component::Field::Rioxx2'}{params}{disable} = 0;

# New report role for the admin user
push @{$c->{user_roles}->{admin}}, qw{
        +report
};

$c->{fundref_csv_file} = $c->{"config_path"}."/autocomplete/funderNames";

