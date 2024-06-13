#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";

sub looks_like_perlbrew_builddir;

describe "App::perlbrew#builddir method" => sub {
    it "should return path in \$App::perlbrew::PERLBREW_ROOT normally" => sub {
        local $App::perlbrew::PERLBREW_ROOT = '/perlbrew/root';
        my $app = App::perlbrew->new;

        looks_like_perlbrew_builddir $app->builddir, '/perlbrew/root/build';
    };

    it "should return path relative to root" => sub {
        my $app = App::perlbrew->new;
        $app->root("/fnord");

        looks_like_perlbrew_builddir $app->builddir, "/fnord/build";
    };
};

describe "App::perlbrew->new" => sub {
    it "should accept --builddir args" => sub {
        local $App::perlbrew::PERLBREW_ROOT = '/perlbrew/root';
        my $app = App::perlbrew->new("--builddir" => "/perlbrew/buildroot");

        looks_like_perlbrew_builddir $app->builddir, "/perlbrew/buildroot";
    };
};

done_testing;

sub looks_like_perlbrew_builddir {
    my ($got, $expected) = @_;
    is "$got", "$expected", "builddir is $expected";
    isa_ok $got, 'App::Perlbrew::Path';
}
