#!perl
use strict;
use App::perlbrew;
use File::Temp qw( tempdir );
$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

use Test::More;

my $app = App::perlbrew->new();

my $rd = { type => "cperl", "version" => "5.22.2" };
$app->release_detail_cperl_local("cperl-5.22.2", $rd);

ok defined( $rd->{tarball_url} );
ok defined( $rd->{tarball_name} );

is $rd->{tarball_url}, "https://github.com/perl11/cperl/releases/download/cperl-5.22.2/cperl-5.22.2.tar.gz";
is $rd->{tarball_name}, "cperl-5.22.2.tar.gz";

done_testing;
