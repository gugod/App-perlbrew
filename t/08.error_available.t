#!/usr/bin/env perl
use Test2::V0;

use App::perlbrew;

no warnings 'redefine';
sub App::perlbrew::http_get { "" }

like(
    dies {
        my $app = App::perlbrew->new("available");
        $app->run;
    },
    qr[ERROR:],
    'got Error from available'
);

like(
    dies {
        my $app = App::perlbrew->new("available");
        my $ret = $app->available_perl_distributions();
    },
    qr[ERROR:],
    'got Error from available_perl_distributions'
);

done_testing;
