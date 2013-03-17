use inc::Module::Install;

license 'mit';

all_from 'lib/App/perlbrew.pm';

repository 'git://github.com/gugod/App-perlbrew.git';

requires
    'Devel::PatchPerl'     => '0.84',
    'local::lib'           => '1.008009',
    'Capture::Tiny'        => '0.21',
    'CPAN::Perl::Releases' => '1.06';

test_requires
    'Test::Simple'     => '0.98',
    'Test::More'       => '0',
    'Test::Output'     => '0',
    'Test::Exception'  => '0',
    'Test::NoWarnings' => '0',
    'Test::Spec'       => '0',
    'Path::Class'      => '0',
    'IO::All'          => '0.46',
    'File::Temp'       => '0';

install_script 'bin/perlbrew';

tests 't/*.t';

WriteAll;
