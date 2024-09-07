#!perl
use Test2::V0;
use Test2::Tools::Spec;

use App::perlbrew;
use App::Perlbrew::Util qw(perl_version_to_integer);

use File::Temp qw( tempdir );
$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

#
# This test checks if the sorting order of parsed version is the same as
# the order of @versions array defined below.
#

my @versions = qw(
                     5.003_07
                     5.004
                     5.004_01
                     5.004_02
                     5.004_03
                     5.004_04
                     5.004_05
                     5.005
                     5.005_01
                     5.005_02
                     5.005_03
                     5.005_04
                     5.6.0
                     5.6.1-TRIAL1
                     5.6.1-TRIAL2
                     5.6.1-TRIAL3
                     5.6.1
                     5.6.2
                     5.7.0
                     5.7.1
                     5.7.2
                     5.7.3
                     5.8.0
                     5.8.1
                     5.8.2
                     5.8.3
                     5.8.4
                     5.8.5
                     5.8.6
                     5.8.7
                     5.8.8
                     5.8.9
                     5.9.0
                     5.9.1
                     5.9.2
                     5.9.3
                     5.9.4
                     5.9.5
                     5.10.0-RC1
                     5.10.0-RC2
                     5.10.0
                     5.10.1
                     5.11.0
                     5.11.1
                     5.11.2
                     5.11.3
                     5.11.4
                     5.11.5
                     5.12.0
                     5.12.1-RC1
                     5.12.1-RC2
                     5.12.1
                     5.12.2-RC1
                     5.12.2
                     5.12.3
                     5.12.4-RC1
                     5.12.4-RC2
                     5.12.4
                     5.13.0
                     5.13.1
                     5.13.2
                     5.13.3
                     5.13.4
                     5.13.5
                     5.13.6
                     5.13.7
                     5.13.8
                     5.13.9
                     5.13.10
                     5.13.11
                     5.14.0-RC1
                     5.14.0-RC2
                     5.14.0-RC3
                     5.14.0
                     5.14.1-RC1
                     5.14.1
                     5.14.2-RC1
                     5.14.2
                     5.14.3-RC1
                     5.14.3-RC2
                     5.14.3
                     5.15.0
                     5.15.1
                     5.15.2
                     5.15.3
                     5.15.4
                     5.15.5
                     5.15.6
                     5.15.7
                     5.15.8
                     5.15.9
                     5.16.0-RC0
                     5.16.0-RC1
                     5.16.0-RC2
                     5.16.0
                     5.16.1-RC1
                     5.16.1
                     5.16.2-RC1
                     5.17.0
                     5.17.1
                     5.17.2
                     5.17.3
                     5.17.4
                     5.17.5
             );

subtest "perl_version_to_integer" =>  sub {
    plan @versions - 1;

    my @versions_i = map { perl_version_to_integer($_) } @versions;
    for my $i (0 .. $#versions_i-1) {
        ok( $versions_i[$i] < $versions_i[$i+1], "$versions[$i] < $versions[$i+1]");
    }
};

subtest "comparable_perl_version" =>  sub {
    plan 0+@versions;

    for my $v (@versions) {
        my $n = App::perlbrew->comparable_perl_version($v);
        like($n, qr/\-? [0-9]+/x, "can build comparable version from: $v");
    }
};

subtest "blead is the biggest" => sub {
    plan 0+@versions;
    my $b = perl_version_to_integer("blead");
    for my $v (@versions) {
        my $n = perl_version_to_integer($v);
        ok $b > $n, "blead is bigger than $v";
    }
};

done_testing;
