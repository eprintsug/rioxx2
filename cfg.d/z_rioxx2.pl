#default cfg options


# Enable core RIOXX2 plugins
$c->{plugins}{'Export::RIOXX2'}{params}{disable} = 0;
$c->{plugins}{"Screen::EPrint::RIOXX2"}{params}{disable} = 0;
$c->{plugins}{'InputForm::Component::Field::RIOXX2'}{params}{disable} = 0;
# Enable optional RIOXX2 plugins for reporting framework (https://github.com/eprints/reports)
$c->{plugins}{"Screen::Report::RIOXX2"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2014"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2014_only"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2015_only"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2016_only"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2017_only"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2018_only"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2019_only"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2020_only"}{params}{disable} = 0;
$c->{plugins}{"Screen::Report::RIOXX2::2021_only"}{params}{disable} = 0;
$c->{plugins}{"Export::Report::CSV::RIOXX2"}{params}{disable} = 0;
