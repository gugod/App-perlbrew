#!/usr/bin/env perl
use strict;
use warnings;

use Test::More import => [ qw( done_testing like subtest ) ];
use File::Temp qw( tempdir );

my $actual_status_code = 42;

BEGIN {
    *CORE::GLOBAL::system = sub {
        return $? = $actual_status_code << 8;
    };
}

use App::Perlbrew::Path;
use App::Perlbrew::HTTP qw(http_download);

local $ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );

subtest "The exit status code of curl", sub {
    my $error = http_download( "https://example.com/whatever.tar.gz",
        App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT)->child("whatever.tar.gz") );

    like $error, qr/^ERROR .+ Exit\ code: .+ ${actual_status_code}/xs;
};

done_testing;
