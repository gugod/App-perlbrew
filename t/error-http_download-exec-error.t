#!/usr/bin/env perl
use strict;
use warnings;

use Test::More import => [ qw( done_testing like subtest ) ];
use File::Temp qw( tempdir );

BEGIN {
    *CORE::GLOBAL::system = sub {
        return $? = -1
    };
}

use App::Perlbrew::Path;
use App::Perlbrew::HTTP qw(http_download);

local $ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );

subtest "The exit status code of curl", sub {
    my $error = http_download( "https://example.com/whatever.tar.gz",
        App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT)->child("whatever.tar.gz") );

    like $error, qr/^ERROR: Failed to execute the command/;
};

done_testing;
