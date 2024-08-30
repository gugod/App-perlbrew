package PerlbrewTestHelpers;
use Test2::V0;
use Test2::Plugin::IOEvents;

use Exporter 'import';
our @EXPORT_OK = qw(stdout_like);

# Replacements of Test::Output made by using Test2::Plugin::IOEvents

sub stdout_like {
    my ($cb, $re, $desc) = @_;
    my $events = intercept { $cb->() };
    my $out = join "", map { $_->details } map { @{ $_->facets->{info} } }@$events;
    like($out, $re, $desc);
}


1;
