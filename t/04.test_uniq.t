#!/usr/bin/env perl
use strict;
use warnings;
use lib qw(lib);
use English qw( -no_match_vars );
use Test::More tests => 1;

use App::perlbrew;

my $app = App::perlbrew->new();

my @values = ("a", "a", "b", "c");
my @uniq_values = ("a",  "b", "c");

my @a = $app->uniq(@values);
my @b = $app->uniq(@uniq_values);

is_deeply \@a, \@b, "Successfully uniquified an array.";
