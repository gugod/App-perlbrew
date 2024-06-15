#!/usr/bin/env perl
use Test2::V0;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

use App::perlbrew;
{
    no warnings 'redefine';
    sub App::perlbrew::http_download { return "ERROR" }
}

like(
    dies {
        my $app = App::perlbrew->new("install", "perl-blead");
        $app->run;
    },
    qr[ERROR: Failed to download https://.+/blead\.tar\.gz],
    'install blead-perl failed'
);

like(
    dies {
        my $app = App::perlbrew->new("install", "blead");
        $app->run;
    },
    qr[ERROR: Failed to download https://.+/blead\.tar\.gz],
    'install blead failed'
);

done_testing;
