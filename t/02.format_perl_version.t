#!/usr/bin/env perl
use Test2::V0;
use English qw( -no_match_vars );

use App::perlbrew;
use Test2::Plugin::NoWarnings;

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
    {
        raw    => q{5.008},
        parsed => q{5.8.0},
    },
);

plan scalar @test_cases;
{
    my $app = App::perlbrew->new();
 TEST:
    foreach my $test (@test_cases) {
        is( $app->format_perl_version( $test->{raw} ),
            $test->{parsed}, "$test->{raw} -> $test->{parsed}" );
    }
}
