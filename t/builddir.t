#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use Test::Spec;

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

runtests unless caller;

sub looks_like_perlbrew_builddir {
    my ($got, $expected) = @_;

    my ($ok, $stack);

    ($ok, $stack) = Test::Deep::cmp_details "$got", "$expected";
    unless ($ok) {
        fail;
        diag Test::Deep::deep_diag $stack;
        return;
    }

    return Test::Deep::cmp_deeply $got, Isa ('App::Perlbrew::Path');
}
