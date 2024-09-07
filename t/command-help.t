#!/usr/bin/env perl
use Test2::V0;
use FindBin;
use lib $FindBin::Bin;
use App::perlbrew;
require "test2_helpers.pl";

my $bin_perlbrew = file(__FILE__)->dirname->dirname->child("script")->child("perlbrew");
my $perl = $^X;

#
# Doing `App::perlbrew->new("help")->run` will make this test program exit(),
# that's why we use backtick to test.
#

subtest "`perlbrew` should print some nice message and instruct user to read help for individual commands" => sub {
    my $out = `$perl -Ilib $bin_perlbrew help`;
    like $out, qr/perlbrew help <command>/si;
};

subtest "`perlbrew -h` should print short version of help message and instruct user to read longer version" => sub {
    my $out1 = `$perl -Ilib $bin_perlbrew --help`;
    my $out2 = `$perl -Ilib $bin_perlbrew -h`;

    is $out2, $out1;
    like $out1, qr/^    See `perlbrew help` for the full documentation/m;
    unlike $out1, qr/^CONFIGURATION$/m;
};

subtest "`perlbrew help` should should the lengthy version " => sub {
    my $out = `$perl -Ilib $bin_perlbrew help`;
    like $out, qr/^CONFIGURATION$/m;
};

subtest "`perlbrew help` should instruct user to read help for individual commands." => sub {
    my $out = `$perl -Ilib $bin_perlbrew help`;
    like $out, qr/perlbrew help <command>/si;
};

subtest "`perlbrew help install` should show the options for install command" => sub {
    my $out = `$perl -Ilib $bin_perlbrew help install`;
    like $out, qr/^Options for "install" command:/msi;
    like $out, qr/--force/si;
    like $out, qr/--notest/si;
};

done_testing;
