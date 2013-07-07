#!/usr/bin/env perl

use strict;
use Test::More;
use App::perlbrew;
use FindBin qw($RealBin);

my @test_files = (<$RealBin/*.t>)[0..9];

for my $i (0..$#test_files) {
    my $t = $test_files[$i];
    my $u = $test_files[$i - 1];
    my $should_be_same = App::perlbrew::files_are_the_same($t, $t);
    my $should_not_be_same = App::perlbrew::files_are_the_same($t, $u);

    ok ($^O eq 'MSWin32' xor $should_be_same); # should return false on win32
    ok !$should_not_be_same;
}

done_testing;
