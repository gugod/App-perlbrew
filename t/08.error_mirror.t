#!/usr/bin/env perl
use strict;
use warnings;
use lib qw(lib);
use App::perlbrew;
use Test::More;
use Test::Exception;

no warnings 'redefine';
sub App::perlbrew::http_get { "" }

throws_ok(
    sub {
        my $app = App::perlbrew->new("mirror");
        $app->run;
    },
    qr"ERROR: Failed to retrieve the mirror list."
);

done_testing;
