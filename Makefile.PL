use inc::Module::Install;

license 'mit';

all_from 'lib/App/perlbrew.pm';

repository 'git://github.com/gugod/App-perlbrew.git';

requires
    'File::Path::Tiny'     => '0.3',
    'Devel::PatchPerl'     => '0.74',
    'local::lib'           => '1.008004',
    'Capture::Tiny'        => '0.19',
    'CPAN::Perl::Releases' => '0.68';

test_requires
    'Test::Simple'    => '0.98',
    'Test::More'      => '0',
    'Test::Output'    => '0',
    'Test::Exception' => '0',
    'Test::Spec'      => '0',
    'Path::Class'     => '0',
    'IO::All'         => '0',
    'File::Temp'      => '0';

install_script 'bin/perlbrew';

tests 't/*.t';

WriteAll;
