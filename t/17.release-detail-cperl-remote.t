#!perl
use strict;
use App::perlbrew;
use File::Temp qw( tempdir );
$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

use Test::More;

unless ($ENV{TEST_LIVE}) {
    plan skip_all => 'These tests send HTTP requests. Set env TEST_LIVE=1 to really run them.';
}

my $app = App::perlbrew->new();

subtest 'Unknown version, expecting error', sub {
    my ($error, $rd) = $app->release_detail_cperl_remote("xxx");
    ok $error, "Errored, as expected";
    ok defined($rd);
};

for my $version ("5.27.1", "5.30.0") {
    subtest "Known version ($version), expecting success", sub {
        my $rd = { type => "cperl", "version" => $version };
        $app->release_detail_cperl_remote("cperl-${version}", $rd);

        ok defined( $rd->{tarball_url} );
        ok defined( $rd->{tarball_name} );

        is $rd->{tarball_url}, "https://github.com/perl11/cperl/releases/download/cperl-${version}/cperl-${version}.tar.gz";
        is $rd->{tarball_name}, "cperl-${version}.tar.gz";
    }
}

done_testing;
