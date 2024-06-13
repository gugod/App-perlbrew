#!/usr/bin/env perl
use Test2::V0;

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

my $error = http_download( "https://example.com/whatever.tar.gz",
    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT)->child("whatever.tar.gz") );

like $error, qr/^ERROR .+ Exit\ code: .+ ${actual_status_code}/xs,
    "The exit status code of curl is ${actual_status_code}";

done_testing;
