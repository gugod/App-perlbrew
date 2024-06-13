#!/usr/bin/env perl
use Test2::V0;

use File::Temp qw(tempdir);

use App::perlbrew;
use App::Perlbrew::Path;

my $fakehome = tempdir( CLEANUP => 1 );

$ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT = App::Perlbrew::Path->new($fakehome)->child("perl5")->stringify;

like(
    dies {
        my $app = App::perlbrew->new("install", "perl-5.36.0");
        $app->run;
    },
    qr[ERROR: .*perlbrew init.*],
    "installing a perl before initializing perlbrew fails"
);

done_testing;
