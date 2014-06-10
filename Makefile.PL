use inc::Module::Install;

license 'mit';

all_from 'lib/App/perlbrew.pm';

repository 'git://github.com/gugod/App-perlbrew.git';

requires
    'CPAN::Perl::Releases' => '1.74',
    'Capture::Tiny'        => '0.24',
    'Devel::PatchPerl'     => '1.24',
    'Pod::Parser'          => '1.62',
    'Pod::Usage'           => '1.63',
    'local::lib'           => '2.000012';

test_requires
    'ExtUtils::MakeMaker'  => '6.86',
    'File::Temp'           => '0.2304',
    'IO::All'              => '0.51',
    'Path::Class'          => '0.33',
    'Test::Exception'      => '0.32',
    'Test::More'           => '1.001002',
    'Test::NoWarnings'     => '1.04',
    'Test::Output'         => '1.03',
    'Test::Simple'         => '1.001002',
    'Test::Spec'           => '0.47';

install_script 'bin/perlbrew';

tests 't/*.t';

makemaker_args(
    dist => {
        COMPRESS => "zopfli -i50",
    }
);

WriteAll;
