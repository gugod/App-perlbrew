#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use File::Temp qw(tempdir);
use Test::Deep qw[];
use Test::Spec;

sub looks_like_perlbrew_root;

local $App::perlbrew::PERLBREW_ROOT = '/perlbrew/root';
local $ENV{PERLBREW_ROOT} = '/env/root';
local $ENV{HOME} = '/home';

describe "App::perlbrew#root method" => sub {
    it "should return \$App::perlbrew::PERLBREW_ROOT if provided" => sub {
        my $app = App::perlbrew->new;

        looks_like_perlbrew_root $app->root, '/perlbrew/root';
    };

    it "should default to \$ENV{PERLBREW_ROOT} if provided" => sub {
        local $App::perlbrew::PERLBREW_ROOT;

        my $app = App::perlbrew->new;

        looks_like_perlbrew_root $app->root, '/env/root';
    };

    it "should default to \$ENV{HOME} subpath" => sub {
        local $App::perlbrew::PERLBREW_ROOT;
        local $ENV{PERLBREW_ROOT};

        my $app = App::perlbrew->new;

        looks_like_perlbrew_root $app->root, '/home/perl5/perlbrew';
    };

    it "should return the instance property of 'root' if set" => sub {
        my $app = App::perlbrew->new;
        $app->root("/fnord");

        looks_like_perlbrew_root $app->root, "/fnord";
    };
};

describe "App::perlbrew->new" => sub {
    it "should accept --root args and treat it as the value of PERLBREW_ROOT for the instance" => sub {
        my $temp_perlbrew_root = tempdir( CLEANUP => 1);

        my $app = App::perlbrew->new("--root" => $temp_perlbrew_root);

        looks_like_perlbrew_root $app->root, $temp_perlbrew_root;
    };
};

runtests unless caller;

sub looks_like_perlbrew_root {
    my ($got, $expected) = @_;

    my ($ok, $stack);

    ($ok, $stack) = Test::Deep::cmp_details "$got", "$expected";
    unless ($ok) {
        fail;
        diag "Return value comparison failed";
        diag Test::Deep::deep_diag $stack;
        return;
    }

    ($ok, $stack) = Test::Deep::cmp_details "$got", "$App::perlbrew::PERLBREW_ROOT";
    unless ($ok) {
        fail;
        diag "Global \$PERLBREW_ROOT comparison failed";
        diag Test::Deep::deep_diag $stack;
        return;
    }

    return Test::Deep::cmp_deeply $got, Isa ('App::Perlbrew::Path::Root');
}

