#!/usr/bin/env perl
use strict;
use warnings;
use English qw( -no_match_vars );
use Test::More;
use lib qw(lib);

use App::perlbrew;

my @test_cases = (
    {
        raw    => q{5.008008},
        parsed => q{5.8.8},
    },
    {
        raw    => q{5.010001},
        parsed => q{5.10.1},
    },
    {
        raw    => q{5.012002},
        parsed => q{5.12.2},
    },
);

{
    my $app = App::perlbrew->new();
  TEST:
    foreach my $test (@test_cases) {
        is( $app->format_perl_version( $test->{raw} ),
            $test->{parsed}, "$test->{raw} -> $test->{parsed}" );
    }
    done_testing();
}
