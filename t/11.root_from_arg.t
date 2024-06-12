#!/usr/bin/env perl
use Test2::V0;
use Test2::Tools::Spec;
use Test2::Tools::ClassicCompare qw/is_deeply/;
use Data::Dumper;

use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";

use File::Temp qw(tempdir);

sub looks_like_perlbrew_root;

# We will override these in the tests below
local $App::perlbrew::PERLBREW_ROOT;
local $ENV{PERLBREW_ROOT};
local $ENV{HOME};

describe "App::perlbrew#root method" => sub {
    before_each init => sub {
        $App::perlbrew::PERLBREW_ROOT = '/perlbrew/root';
        $ENV{PERLBREW_ROOT} = '/env/root';
        $ENV{HOME} = '/home';
    };

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

done_testing;

sub looks_like_perlbrew_root {
    my ($got, $expected) = @_;

    is_deeply($got, $expected,
        'Return value comparison failed') or return;

    is_deeply("$got", "$App::perlbrew::PERLBREW_ROOT",
        "Global \$PERLBREW_ROOT comparison failed") or return;

    isa_ok($got, 'App::Perlbrew::Path::Root');
}

