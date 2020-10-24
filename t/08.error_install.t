#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;
use File::Temp qw(tempdir);

use App::perlbrew;

$App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );
$App::perlbrew::PERLBREW_HOME = tempdir( CLEANUP => 1 );
$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT;

App::Perlbrew::Path->new ($ENV{PERLBREW_ROOT})->child ("perls")->mkpath;
App::Perlbrew::Path->new ($ENV{PERLBREW_ROOT})->child ("build")->mkpath;
App::Perlbrew::Path->new ($ENV{PERLBREW_ROOT})->child ("dists")->mkpath;

no warnings 'redefine';
sub App::perlbrew::http_download { return "ERROR" }

throws_ok(
    sub {
        my $app = App::perlbrew->new("install", "perl-5.12.3");
        $app->run;
    },
    qr[ERROR: Failed to download .*perl-5.12.3.*]
);

done_testing;
