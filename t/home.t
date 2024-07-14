#!/usr/bin/env perl
use Test2::V0;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";

sub looks_like_perlbrew_home;

local $App::perlbrew::PERLBREW_HOME = '/perlbrew/home';
local $ENV{PERLBREW_HOME} = '/env/home';
local $ENV{HOME} = '/home';

subtest "App::perlbrew#home method" => sub {
    subtest "it should return \$App::perlbrew::PERLBREW_HOME if provided" => sub {
        my $app = App::perlbrew->new;

        looks_like_perlbrew_home $app->home, '/perlbrew/home';
    };

    subtest "it should default to \$ENV{PERLBREW_HOME} if provided" => sub {
        local $App::perlbrew::PERLBREW_HOME;

        my $app = App::perlbrew->new;

        looks_like_perlbrew_home $app->home, '/env/home';
    };

    subtest "it should default to \$ENV{HOME} subpath" => sub {
        local $App::perlbrew::PERLBREW_HOME;
        local $ENV{PERLBREW_HOME};

        my $app = App::perlbrew->new;

        looks_like_perlbrew_home $app->home, '/home/.perlbrew';
    };

    subtest "it should return the instance property of 'home' if set" => sub {
        my $app = App::perlbrew->new;
        $app->home("/fnord");

        looks_like_perlbrew_home $app->home, "/fnord";
    };
};

done_testing;

sub looks_like_perlbrew_home {
    my ($got, $expected) = @_;

    isa_ok $got, 'App::Perlbrew::Path';
    is "$got", "$expected";
    is "$got", "$App::perlbrew::PERLBREW_HOME";
}
