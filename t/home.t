#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use Test::Deep qw[];
use Test::Spec;

sub looks_like_perlbrew_home;

local $App::perlbrew::PERLBREW_HOME = '/perlbrew/home';
local $ENV{PERLBREW_HOME} = '/env/home';
local $ENV{HOME} = '/home';

describe "App::perlbrew#home method" => sub {
    it "should return \$App::perlbrew::PERLBREW_HOME if provided" => sub {
        my $app = App::perlbrew->new;

        looks_like_perlbrew_home $app->home, '/perlbrew/home';
    };

    it "should default to \$ENV{PERLBREW_HOME} if provided" => sub {
		local $App::perlbrew::PERLBREW_HOME;

        my $app = App::perlbrew->new;

        looks_like_perlbrew_home $app->home, '/env/home';
    };

    it "should default to \$ENV{HOME} subpath" => sub {
		local $App::perlbrew::PERLBREW_HOME;
		local $ENV{PERLBREW_HOME};

        my $app = App::perlbrew->new;

        looks_like_perlbrew_home $app->home, '/home/.perlbrew';
    };

    it "should return the instance property of 'home' if set" => sub {
        my $app = App::perlbrew->new;
        $app->home("/fnord");

        looks_like_perlbrew_home $app->home, "/fnord";
    };
};

runtests unless caller;

sub looks_like_perlbrew_home {
	my ($got, $expected) = @_;

	my ($ok, $stack);

	($ok, $stack) = Test::Deep::cmp_details "$got", "$expected";
	unless ($ok) {
		fail;
		diag "Return value comparison failed";
		diag Test::Deep::deep_diag $stack;
		return;
	}

	($ok, $stack) = Test::Deep::cmp_details "$got", "$App::perlbrew::PERLBREW_HOME";
	unless ($ok) {
		fail;
		diag "Global \$PERLBREW_HOME comparison failed";
		diag Test::Deep::deep_diag $stack;
		return;
	}

	return Test::Deep::cmp_deeply $got, Isa ('App::Perlbrew::Path');
}

