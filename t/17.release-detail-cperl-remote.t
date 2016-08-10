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

my $rd = { type => "cperl", "version" => "5.24.0" };
$app->release_detail_cperl_remote("cperl-5.24.0", $rd);

ok defined( $rd->{tarball_url} );
ok defined( $rd->{tarball_name} );

is $rd->{tarball_url}, "https://github.com/perl11/cperl/releases/download/cperl-5.24.0/cperl-5.24.0.tar.gz";
is $rd->{tarball_name}, "cperl-5.24.0.tar.gz";

done_testing;
