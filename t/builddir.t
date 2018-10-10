#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use Test::Spec;

describe "App::perlbrew#builddir method" => sub {
    it "should return path in \$App::perlbrew::PERLBREW_ROOT normally" => sub {
		local $App::perlbrew::PERLBREW_ROOT = '/perlbrew/root';
        my $app = App::perlbrew->new;

        is $app->builddir, '/perlbrew/root/build';
    };

    it "should return path relative to root" => sub {
        my $app = App::perlbrew->new;
        $app->root("/fnord");

        is $app->builddir, "/fnord/build";
    };
};

describe "App::perlbrew->new" => sub {
    it "should accept --builddir args" => sub {
		local $App::perlbrew::PERLBREW_ROOT = '/perlbrew/root';
        my $app = App::perlbrew->new("--builddir" => "/perlbrew/buildroot");

        is $app->builddir, "/perlbrew/buildroot";
    };
};

runtests unless caller;
