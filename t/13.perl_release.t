#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use File::Temp qw(tempdir);
use Test::Spec;
use Test::Exception;

describe "App::perlbrew#perl_release method, given a valid perl version, " => sub {
    it "returns the perl dist tarball file name, and its download url" => sub {
        my $app = App::perlbrew->new;

        for my $version (qw(5.14.2 5.10.1 5.10.0 5.003_07 5.004_05)) {
            my ($ball, $url) = $app->perl_release($version);
            like $ball, qr/perl-?${version}.tar.(bz2|gz)/;
            like $url, qr/${ball}$/;
        }
    };
};

runtests unless caller;
