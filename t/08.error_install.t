#!/usr/bin/env perl
use strict;
use warnings;
use lib qw(lib);
use Test::More;
use Test::Exception;
use Path::Class;

BEGIN {
    $ENV{PERLBREW_ROOT} = file(__FILE__)->dir->subdir("mock_perlbrew_root");
}

use App::perlbrew;

App::perlbrew::rmpath( $ENV{PERLBREW_ROOT} );
App::perlbrew::mkpath( dir($ENV{PERLBREW_ROOT})->subdir("perls") );
App::perlbrew::mkpath( dir($ENV{PERLBREW_ROOT})->subdir("build") );

no warnings 'redefine';
sub App::perlbrew::http_get { "" }

throws_ok(
    sub {
        my $app = App::perlbrew->new("install", "perl-5.12.3");
        $app->run;
    },
    qr[ERROR: Failed to download perl-5.12.3 tarball.]
);

done_testing;
