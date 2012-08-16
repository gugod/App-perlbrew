#!/usr/bin/env perl
use strict;
use warnings;
use lib qw(lib);
use Test::More;
use Test::Exception;
use Path::Class;
use File::Temp qw(tempdir);

use App::perlbrew;

$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

App::perlbrew::mkpath( dir($ENV{PERLBREW_ROOT})->subdir("perls") );
App::perlbrew::mkpath( dir($ENV{PERLBREW_ROOT})->subdir("build") );
App::perlbrew::mkpath( dir($ENV{PERLBREW_ROOT})->subdir("dists") );

no warnings 'redefine';
sub App::perlbrew::http_get {
    my ($url, $header, $cb) = @_;
    if (ref($header) eq 'CODE') {
        $cb = $header;
        $header = undef;
    }
    $cb->(undef);
}

throws_ok(
    sub {
        my $app = App::perlbrew->new("install", "perl-5.12.3");
        $app->run;
    },
    qr[ERROR: Failed to download .*perl-5.12.3.*]
);

done_testing;
