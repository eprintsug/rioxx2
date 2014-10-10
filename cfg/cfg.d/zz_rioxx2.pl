
# Enable core RIOXX2 plugins
$c->{plugins}{'Export::RIOXX2'}{params}{disable} = 0;
$c->{plugins}{"Screen::EPrint::RIOXX2"}{params}{disable} = 0;
$c->{plugins}{'InputForm::Component::Field::Rioxx2'}{params}{disable} = 0;

# Enable optional RIOXX2 plugins for reporting framework (https://github.com/eprints/reports)
$c->{plugins}{"Screen::Report::Rioxx2"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::Rioxx2::Articles"}{params}{disable} = 0;
$c->{plugins}{"Export::Report::CSV::Rioxx2"}{params}{disable} = 0;

$c->{fundref_csv_file} = $c->{"config_path"}."/autocomplete/funderNames";
