#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test_helpers.pl';

use Test::More;
use Test::Exception;

use App::perlbrew;
{
    no warnings 'redefine';
    sub App::perlbrew::http_download { return "ERROR" }
}

throws_ok(
    sub {
        my $app = App::perlbrew->new("install", "perl-blead");
        $app->run;
    },
    qr[ERROR: Failed to download https://.+/blead\.tar\.gz]
);

throws_ok(
    sub {
        my $app = App::perlbrew->new("install", "blead");
        $app->run;
    },
    qr[ERROR: Failed to download https://.+/blead\.tar\.gz]
);

done_testing;
