#!/usr/bin/env perl
use Test2::V0;

use App::perlbrew;

my $app = App::perlbrew->new();
my @perls = $app->installed_perls;

unless(@perls) {
    skip_all("No perl installation under PERLBREW_ROOT");
}

for my $perl (@perls) {
    is ref($perl), 'HASH';
    ok defined $perl->{name},       "Name: $perl->{name}";
    ok defined $perl->{version},    "Version: $perl->{version}";
    ok defined $perl->{is_current}, "Current?: " . ($perl->{is_current} ? "true" : "false");
}

done_testing;
