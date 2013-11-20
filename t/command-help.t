#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test_helpers.pl";

use Test::Spec;

my $bin_perlbrew = file(__FILE__)->dir->parent->subdir("bin")->file("perlbrew");
my $perl = $^X;

#
# Doing `App::perlbrew->new("help")->run` will make this test program exit(),
# that's why we use backtick to test.
#


describe "`perlbrew`" => sub {
    it "should print some nice message and instruct user to read help for individual commands" => sub {
        my $out = `$perl -Ilib $bin_perlbrew help`;
        like $out, qr/perlbrew help <command>/si;
    };
};

describe "`perlbrew help`" => sub {
    it "should instruct user to read help for individual commands." => sub {
        my $out = `$perl -Ilib $bin_perlbrew help`;
        like $out, qr/perlbrew help <command>/si;
    };

    it "should be the same as doing `perlbrew -h` or `perlbrew --help`" => sub {
        my $out1 = `$perl -Ilib $bin_perlbrew help`;
        my $out2 = `$perl -Ilib $bin_perlbrew -h`;
        my $out3 = `$perl -Ilib $bin_perlbrew --help`;
        is $out1, $out2;
        is $out1, $out3;
    };
};

describe "`help install`" => sub {
    it "should show the options for install command" => sub {
        my $out = `$perl -Ilib $bin_perlbrew help install`;
        like $out, qr/^Options for "install" command:/msi;
        like $out, qr/--force/si;
        like $out, qr/--notest/si;
    };
};

runtests unless caller;

