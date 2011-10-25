#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

mock_perlbrew_install("perl-5.12.3");

use Test::Spec;
use Test::Output qw(stdout_is stdout_from stdout_like);

my $bin_perlbrew = file(__FILE__)->dir->parent->subdir("bin")->file("perlbrew");

describe "help" => sub {
    it "should instruct user to read help for individual commands." => sub {
        my $out = `perl -Ilib $bin_perlbrew help`;
        like $out, qr/perlbrew help <command>/si;
    };
};

runtests unless caller;

