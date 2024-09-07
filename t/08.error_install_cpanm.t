#!/usr/bin/env perl
use Test2::V0;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require 'test2_helpers.pl';

no warnings 'redefine';
sub App::perlbrew::http_get { "" }

like(
    dies {
        my $app = App::perlbrew->new("install-cpanm");
        $app->run;
    },
    qr[ERROR: Failed to retrieve cpanm executable.]
);

done_testing;
