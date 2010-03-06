use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/App/perlbrew.pm';

requires 'LWP'   => 5.828;

install_script 'bin/perlbrew';

tests 't/*.t';

WriteAll;
