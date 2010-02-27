use strict;
use warnings;
use inc::Module::Install;
use Module::Install::ReadmePodFromPod;

all_from 'lib/App/perlbrew.pm';
readme_pod_from 'lib/App/perlbrew.pm';
readme_from 'lib/App/perlbrew.pm';

requires 'LWP'   => 5.828;

install_script 'bin/perlbrew';

tests 't/*.t';
author_tests 'xt/*.t';

WriteAll;
