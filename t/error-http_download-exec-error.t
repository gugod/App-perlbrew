#!/usr/bin/env perl
use Test2::V0;

use File::Temp qw( tempdir );

BEGIN {
    *CORE::GLOBAL::system = sub {
        return $? = -1
    };
}

use App::Perlbrew::Path;
use App::Perlbrew::HTTP qw(http_download);

local $ENV{PERLBREW_ROOT} = $App::perlbrew::PERLBREW_ROOT = tempdir( CLEANUP => 1 );

my $error = http_download( "https://example.com/whatever.tar.gz",
    App::Perlbrew::Path->new($App::perlbrew::PERLBREW_ROOT)->child("whatever.tar.gz") );

like $error, qr/^ERROR: Failed to execute the command/, "The exit status code of curl is -1";

done_testing;
