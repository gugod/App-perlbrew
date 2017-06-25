
use FindBin '$Bin';
BEGIN { push @INC, $Bin; }

use inc::Module::Install;

license 'mit';

all_from 'lib/App/perlbrew.pm';

abstract 'App::perlbrew - Manage perl installations in your $HOME';

repository 'git://github.com/gugod/App-perlbrew.git';

requires
    'CPAN::Perl::Releases' => '3.24',
    'Capture::Tiny'        => '0.36',
    'Devel::PatchPerl'     => '1.40',
    'Pod::Parser'          => '1.63',
    'Pod::Usage'           => '1.68',
    'local::lib'           => '2.000014';

test_requires
    'ExtUtils::MakeMaker'  => '6.86',
    'File::Which'          => '1.21',
    'File::Temp'           => '0.2304',
    'IO::All'              => '0.51',
    'Path::Class'          => '0.33',
    'Test::Exception'      => '0.32',
    'Test::More'           => '1.001002',
    'Test::NoWarnings'     => '1.04',
    'Test::Output'         => '1.03',
    'Test::Simple'         => '1.001002',
    'Test::Spec'           => '0.47';

author_requires
    'Pod::Markdown'        => '2.002';

install_script 'bin/perlbrew';

tests 't/*.t';

makemaker_args(
    dist => {
        COMPRESS => "zopfli -i50",
    }
);

WriteAll;
