#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;
use File::Temp qw(tempdir);

use App::perlbrew;
use App::Perlbrew::Path;

my $fakehome = tempdir( CLEANUP => 1 );

$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT = App::Perlbrew::Path->new($fakehome)->child("perl5")->stringify;

throws_ok(
    sub {
        my $app = App::perlbrew->new("install", "perl-5.36.0");
        $app->run;
    },
    qr[ERROR: .*perlbrew init.*]
);

done_testing;
