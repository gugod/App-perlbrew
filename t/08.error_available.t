#!/usr/bin/env perl
use strict;
use warnings;

use App::perlbrew;
use Test::More;
use Test::Exception;

no warnings 'redefine';
sub App::perlbrew::http_get { "" }

throws_ok(
    sub {
        my $app = App::perlbrew->new("available");
        $app->run;
    },
    qr[ERROR:]
);

throws_ok(
    sub {
        my $app = App::perlbrew->new("available");
        my $ret = $app->available_perl_distributions();
    },
    qr[ERROR:]
);

throws_ok(
    sub {
        my $app = App::perlbrew->new("available");
        my $ret = $app->available_cperl_distributions();
    },
    qr[ERROR:]
);


done_testing;
